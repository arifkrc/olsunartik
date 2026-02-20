import 'package:drift/drift.dart';

// ============================================================================
// SYNC MIXIN - Tüm Senkronize Edilecek Tablolar için Ortak Alanlar
// ============================================================================

mixin SyncMixin on Table {
  /// Local unique ID (autoincrement)
  IntColumn get localId => integer().autoIncrement()();

  /// Server'dan gelen gerçek ID
  TextColumn get remoteId => text().nullable()();

  /// Senkronizasyon durumu: synced, pending_insert, pending_update, pending_delete
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending_insert'))();

  /// Son değişiklik zamanı (conflict resolution için)
  DateTimeColumn get lastModified =>
      dateTime().withDefault(currentDateAndTime)();

  /// Oluşturulma zamanı
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// PARENT TABLO: Sipariş
// ============================================================================

@DataClassName('Siparis')
class Siparisler extends Table with SyncMixin {
  @override
  String get tableName => 'siparisler';

  // İş alanları
  TextColumn get musteriAdi => text().withLength(min: 1, max: 255)();
  TextColumn get siparisTarihi => text()(); // ISO 8601 format
  RealColumn get toplamTutar => real().withDefault(const Constant(0.0))();
  TextColumn get durum => text().withDefault(
    const Constant('taslak'),
  )(); // taslak, onaylandi, tamamlandi
  TextColumn get aciklama => text().nullable()();

  // Opsiyonel: Kullanıcı tracking
  TextColumn get olusturanKullanici => text().nullable()();
}

// ============================================================================
// CHILD TABLO: SiparişKalemi
// ============================================================================

@DataClassName('SiparisKalemi')
class SiparisKalemleri extends Table with SyncMixin {
  @override
  String get tableName => 'siparis_kalemleri';

  // Parent ilişkisi (Foreign Key)
  IntColumn get siparisLocalId => integer().references(Siparisler, #localId)();
  TextColumn get siparisRemoteId =>
      text().nullable()(); // Parent'ın remote ID'si

  // İş alanları
  TextColumn get urunKodu => text().withLength(min: 1, max: 100)();
  TextColumn get urunAdi => text().withLength(min: 1, max: 255)();
  IntColumn get miktar => integer().withDefault(const Constant(1))();
  RealColumn get birimFiyat => real().withDefault(const Constant(0.0))();
  RealColumn get toplamFiyat => real().withDefault(const Constant(0.0))();

  // Computed alan (Drift computed columns özelliği yoksa, bu manuel hesaplanmalı)
  // toplamFiyat = miktar * birimFiyat
}

/*
// ============================================================================
// SYNC QUEUE - Senkronizasyon Kuyrugu (Opsiyonel ama önerilir)
// ============================================================================

// NOTE: Temporarily disabled due to Drift override issues
// You can implement a simple queue in memory instead

/*
@DataClassName('SyncQueueItem')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableNameField => text()();
  IntColumn get recordLocalId => integer()();
  TextColumn get operation => text()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get enqueuedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}
*/

// ============================================================================
// SYNC LOG - Senkronizasyon Geçmişi (İzleme için)
// ============================================================================

// NOTE: Temporarily disabled due to Drift override issues
// You can log to console or use a logging package instead

/*
@DataClassName('SyncLog')
class SyncLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableNameField => text()();
  IntColumn get recordLocalId => integer()();
  TextColumn get operation => text()();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  IntColumn get duration => integer().nullable()();
}
*/
*/

// ============================================================================
// KULLANIM ÖRNEĞİ - INSERT
// ============================================================================

/*
// 1. Sipariş Oluştur (Offline)
final siparis = SiparislerCompanion(
  musteriAdi: Value('Acme Corp'),
  siparisTarihi: Value(DateTime.now().toIso8601String()),
  toplamTutar: Value(1500.0),
  durum: Value('taslak'),
  syncStatus: Value('pending_insert'), // Otomatik zaten
  lastModified: Value(DateTime.now()),
);

final siparisLocalId = await db.into(db.siparisler).insert(siparis);

// 2. Kalemler Ekle
final kalem1 = SiparisKalemleriCompanion(
  siparisLocalId: Value(siparisLocalId),
  urunKodu: Value('URN-001'),
  urunAdi: Value('Ürün 1'),
  miktar: Value(10),
  birimFiyat: Value(50.0),
  toplamFiyat: Value(500.0),
  syncStatus: Value('pending_insert'),
);

await db.into(db.siparisKalemleri).insert(kalem1);

// 3. İnternet geldiğinde SyncService otomatik çalışır
*/
