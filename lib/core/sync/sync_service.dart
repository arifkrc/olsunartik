import 'dart:async';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../utils/app_logger.dart';

/// Offline-First Sync Service
/// Parent-Child ilişkilerini koruyarak veri senkronizasyonu yapar
class SyncService {
  final AppDatabase _db;
  final Dio _dio;

  bool _isSyncing = false;
  final _syncCompleter = Completer<void>();

  SyncService({required AppDatabase database, required Dio dio})
    : _db = database,
      _dio = dio;

  // ============================================================================
  // ANA SYNC METODU
  // ============================================================================

  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      AppLogger.warning(
        'Senkronizasyon zaten devam ediyor...',
        tag: 'SyncService',
      );
      await _syncCompleter.future;
      return SyncResult.alreadyRunning();
    }

    _isSyncing = true;
    final startTime = DateTime.now();
    final result = SyncResult();

    try {
      AppLogger.sync('Senkronizasyon başladı...');

      // 1. PARENT SYNC - Siparişler
      AppLogger.info('Siparişler senkronize ediliyor...', tag: 'SyncService');
      final siparisResult = await _syncSiparisler();
      result.siparisCount = siparisResult;

      // 2. CHILD SYNC - Sipariş Kalemleri
      AppLogger.info(
        'Sipariş kalemleri senkronize ediliyor...',
        tag: 'SyncService',
      );
      final kalemResult = await _syncSiparisKalemleri();
      result.kalemCount = kalemResult;

      // 3. DELETE SYNC - Silinmiş kayıtlar
      AppLogger.info('Silinen kayıtlar temizleniyor...', tag: 'SyncService');
      await _syncDeletes();

      result.success = true;
      result.duration = DateTime.now().difference(startTime);

      AppLogger.success(
        'Senkronizasyon tamamlandı! '
        'Sipariş: ${result.siparisCount}, '
        'Kalem: ${result.kalemCount}, '
        'Süre: ${result.duration?.inSeconds ?? 0}s',
      );
    } catch (e, stackTrace) {
      result.success = false;
      result.error = e.toString();
      AppLogger.error(
        'Senkronizasyon hatası',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncService',
      );
    } finally {
      _isSyncing = false;
      if (!_syncCompleter.isCompleted) {
        _syncCompleter.complete();
      }
    }

    return result;
  }

  // ============================================================================
  // PARENT SYNC - SİPARİŞLER
  // ============================================================================

  Future<int> _syncSiparisler() async {
    int syncedCount = 0;

    // Pending insert ve update kayıtları al
    final pendingList = await (_db.select(
      _db.siparisler,
    )..where((tbl) => tbl.syncStatus.isNotIn(['synced']))).get();

    if (pendingList.isEmpty) {
      AppLogger.debug('Senkronize edilecek sipariş yok', tag: 'SyncService');
      return 0;
    }

    AppLogger.info(
      '${pendingList.length} sipariş senkronize edilecek',
      tag: 'SyncService',
    );

    for (final siparis in pendingList) {
      try {
        if (siparis.syncStatus == 'pending_insert') {
          // Yeni kayıt - POST
          await _insertSiparis(siparis);
        } else if (siparis.syncStatus == 'pending_update') {
          // Güncellenmiş kayıt - PUT
          await _updateSiparis(siparis);
        }
        syncedCount++;
      } catch (e) {
        AppLogger.error(
          'Sipariş sync hatası (localId: ${siparis.localId})',
          error: e,
          tag: 'SyncService',
        );
        // Hata logla ama devam et
        await _logSyncError('siparisler', siparis.localId, e.toString());
      }
    }

    return syncedCount;
  }

  Future<void> _insertSiparis(Siparis siparis) async {
    // 1. Server'a gönder
    final response = await _dio.post(
      '/api/siparisler',
      data: {
        'musteri_adi': siparis.musteriAdi,
        'siparis_tarihi': siparis.siparisTarihi,
        'toplam_tutar': siparis.toplamTutar,
        'durum': siparis.durum,
        'aciklama': siparis.aciklama,
        'olusturan_kullanici': siparis.olusturanKullanici,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Server error: ${response.statusCode}');
    }

    // 2. Remote ID'yi al
    final remoteId = response.data['id']?.toString();
    if (remoteId == null) {
      throw Exception('Remote ID alınamadı');
    }

    // 3. Local DB'yi güncelle - TRANSACTION içinde
    await _db.transaction(() async {
      // 3a. Sipariş remote_id ve status güncelle
      await (_db.update(
        _db.siparisler,
      )..where((tbl) => tbl.localId.equals(siparis.localId))).write(
        SiparislerCompanion(
          remoteId: Value(remoteId),
          syncStatus: Value('synced'),
          lastModified: Value(DateTime.now()),
        ),
      );

      // 3b. İlgili kalemlere parent remote_id aktar
      await (_db.update(_db.siparisKalemleri)
            ..where((tbl) => tbl.siparisLocalId.equals(siparis.localId)))
          .write(SiparisKalemleriCompanion(siparisRemoteId: Value(remoteId)));
    });

    AppLogger.debug(
      'Sipariş eklendi (localId: ${siparis.localId} → remoteId: $remoteId)',
      tag: 'SyncService',
    );
  }

  Future<void> _updateSiparis(Siparis siparis) async {
    if (siparis.remoteId == null) {
      throw Exception('Update için remote_id gerekli');
    }

    final response = await _dio.put(
      '/api/siparisler/${siparis.remoteId}',
      data: {
        'musteri_adi': siparis.musteriAdi,
        'siparis_tarihi': siparis.siparisTarihi,
        'toplam_tutar': siparis.toplamTutar,
        'durum': siparis.durum,
        'aciklama': siparis.aciklama,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    // Status güncelle
    await (_db.update(
      _db.siparisler,
    )..where((tbl) => tbl.localId.equals(siparis.localId))).write(
      SiparislerCompanion(
        syncStatus: Value('synced'),
        lastModified: Value(DateTime.now()),
      ),
    );

    AppLogger.debug(
      'Sipariş güncellendi (remoteId: ${siparis.remoteId})',
      tag: 'SyncService',
    );
  }

  // ============================================================================
  // CHILD SYNC - SİPARİŞ KALEMLERİ
  // ============================================================================

  Future<int> _syncSiparisKalemleri() async {
    int syncedCount = 0;

    // Pending kayıtları al - SADECE parent'ı synced olanlar
    final pendingList =
        await (_db.select(_db.siparisKalemleri)..where(
              (tbl) =>
                  tbl.syncStatus.isNotIn(['synced']) &
                  tbl.siparisRemoteId.isNotNull(),
            ))
            .get();

    if (pendingList.isEmpty) {
      AppLogger.debug('Senkronize edilecek kalem yok', tag: 'SyncService');
      return 0;
    }

    AppLogger.info(
      '${pendingList.length} kalem senkronize edilecek',
      tag: 'SyncService',
    );

    for (final kalem in pendingList) {
      try {
        if (kalem.syncStatus == 'pending_insert') {
          await _insertKalem(kalem);
        } else if (kalem.syncStatus == 'pending_update') {
          await _updateKalem(kalem);
        }
        syncedCount++;
      } catch (e) {
        AppLogger.error(
          'Kalem sync hatası (localId: ${kalem.localId})',
          error: e,
          tag: 'SyncService',
        );
        await _logSyncError('siparis_kalemleri', kalem.localId, e.toString());
      }
    }

    return syncedCount;
  }

  Future<void> _insertKalem(SiparisKalemi kalem) async {
    final response = await _dio.post(
      '/api/siparis-kalemleri',
      data: {
        'siparis_id': kalem.siparisRemoteId, // Parent'ın remote ID'si
        'urun_kodu': kalem.urunKodu,
        'urun_adi': kalem.urunAdi,
        'miktar': kalem.miktar,
        'birim_fiyat': kalem.birimFiyat,
        'toplam_fiyat': kalem.toplamFiyat,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Server error: ${response.statusCode}');
    }

    final remoteId = response.data['id']?.toString();

    await (_db.update(
      _db.siparisKalemleri,
    )..where((tbl) => tbl.localId.equals(kalem.localId))).write(
      SiparisKalemleriCompanion(
        remoteId: Value(remoteId),
        syncStatus: Value('synced'),
        lastModified: Value(DateTime.now()),
      ),
    );

    AppLogger.debug(
      'Kalem eklendi (localId: ${kalem.localId} → remoteId: $remoteId)',
      tag: 'SyncService',
    );
  }

  Future<void> _updateKalem(SiparisKalemi kalem) async {
    if (kalem.remoteId == null) {
      throw Exception('Update için remote_id gerekli');
    }

    await _dio.put(
      '/api/siparis-kalemleri/${kalem.remoteId}',
      data: {
        'urun_kodu': kalem.urunKodu,
        'urun_adi': kalem.urunAdi,
        'miktar': kalem.miktar,
        'birim_fiyat': kalem.birimFiyat,
        'toplam_fiyat': kalem.toplamFiyat,
      },
    );

    await (_db.update(
      _db.siparisKalemleri,
    )..where((tbl) => tbl.localId.equals(kalem.localId))).write(
      SiparisKalemleriCompanion(
        syncStatus: Value('synced'),
        lastModified: Value(DateTime.now()),
      ),
    );

    AppLogger.debug(
      'Kalem güncellendi (remoteId: ${kalem.remoteId})',
      tag: 'SyncService',
    );
  }

  // ============================================================================
  // DELETE SYNC
  // ============================================================================

  Future<void> _syncDeletes() async {
    // Child'ları önce sil
    await _deleteKalemler();

    // Sonra parent'ları sil
    await _deleteSiparisler();
  }

  Future<void> _deleteKalemler() async {
    final deletedList = await (_db.select(
      _db.siparisKalemleri,
    )..where((tbl) => tbl.syncStatus.equals('pending_delete'))).get();

    for (final kalem in deletedList) {
      if (kalem.remoteId != null) {
        try {
          await _dio.delete('/api/siparis-kalemleri/${kalem.remoteId}');
        } catch (e) {
          AppLogger.warning(
            'Server delete hatası (kalem)',
            error: e,
            tag: 'SyncService',
          );
          // Server'da zaten yoksa devam et
        }
      }

      // Local'den tamamen sil
      await (_db.delete(
        _db.siparisKalemleri,
      )..where((tbl) => tbl.localId.equals(kalem.localId))).go();
    }
  }

  Future<void> _deleteSiparisler() async {
    final deletedList = await (_db.select(
      _db.siparisler,
    )..where((tbl) => tbl.syncStatus.equals('pending_delete'))).get();

    for (final siparis in deletedList) {
      if (siparis.remoteId != null) {
        try {
          await _dio.delete('/api/siparisler/${siparis.remoteId}');
        } catch (e) {
          AppLogger.warning(
            'Server delete hatası (sipariş)',
            error: e,
            tag: 'SyncService',
          );
        }
      }

      await (_db.delete(
        _db.siparisler,
      )..where((tbl) => tbl.localId.equals(siparis.localId))).go();
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  Future<void> _logSyncError(
    String tableName,
    int localId,
    String error,
  ) async {
    // Log using AppLogger utility
    AppLogger.warning('SYNC ERROR [$tableName:$localId]: $error');

    // Additional logging can be implemented here (e.g., Sentry, Firebase Crashlytics)
  }

  /// Pending kayıt sayısını döndür
  Future<int> getPendingCount() async {
    final siparisCount =
        await (_db.select(_db.siparisler)
              ..where((tbl) => tbl.syncStatus.isNotIn(['synced'])))
            .get()
            .then((list) => list.length);

    final kalemCount =
        await (_db.select(_db.siparisKalemleri)
              ..where((tbl) => tbl.syncStatus.isNotIn(['synced'])))
            .get()
            .then((list) => list.length);

    return siparisCount + kalemCount;
  }

  /// Manuel sync tetikle
  void triggerSync() {
    if (!_isSyncing) {
      syncAll();
    }
  }
}

// ============================================================================
// SYNC RESULT MODEL
// ============================================================================

class SyncResult {
  bool success = false;
  int siparisCount = 0;
  int kalemCount = 0;
  Duration? duration;
  String? error;

  SyncResult();

  SyncResult.alreadyRunning()
    : success = false,
      error = 'Sync already in progress';
}
