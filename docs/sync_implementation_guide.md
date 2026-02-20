# Offline-First Senkronizasyon - Uygulama Kılavuzu

## 📦 Gerekli Paketler

```yaml
dependencies:
  drift: ^2.15.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.8.3
  connectivity_plus: ^5.0.0
  dio: ^5.4.0
  riverpod_annotation: ^2.3.0
  flutter_riverpod: ^2.4.0

dev_dependencies:
  drift_dev: ^2.15.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
```

## 🚀 Kurulum Adımları

### 1. Database Oluştur

```bash
# Drift code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

**lib/core/database/database.dart:**

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Siparisler,
  SiparisKalemleri,
  SyncQueue,
  SyncLog,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_db.sqlite'));
    return NativeDatabase(file);
  });
}
```

### 2. Riverpod Providers Oluştur

**lib/core/providers/app_providers.dart:**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../database/database.dart';
import '../sync/sync_service.dart';

part 'app_providers.g.dart';

@riverpod
AppDatabase database(DatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://your-api.com',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));
  
  // Interceptors ekle (auth, logging, etc.)
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
  
  return dio;
}

@riverpod
SyncService syncService(SyncServiceRef ref) {
  final db = ref.watch(databaseProvider);
  final dio = ref.watch(dioProvider);
  
  return SyncService(
    database: db,
    dio: dio,
  );
}
```

### 3. Main.dart'ta Başlat

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Connectivity service'i başlat
    ref.watch(connectivityServiceProvider);
    
    return MaterialApp(
      title: 'Offline-First App',
      home: HomePage(),
    );
  }
}
```

## 📝 Veri Ekleme/Güncelleme (Offline-First)

### Yeni Sipariş Oluştur

```dart
class OrderRepository {
  final AppDatabase _db;
  
  OrderRepository(this._db);
  
  Future<int> createOrder({
    required String musteriAdi,
    required double toplamTutar,
    List<OrderItem>? items,
  }) async {
    return await _db.transaction(() async {
      // 1. Sipariş ekle
      final siparisId = await _db.into(_db.siparisler).insert(
        SiparislerCompanion(
          musteriAdi: Value(musteriAdi),
          siparisTarihi: Value(DateTime.now().toIso8601String()),
          toplamTutar: Value(toplamTutar),
          durum: Value('taslak'),
          syncStatus: Value('pending_insert'), // Otomatik default
          lastModified: Value(DateTime.now()),
        ),
      );
      
      // 2. Kalemleri ekle
      if (items != null) {
        for (final item in items) {
          await _db.into(_db.siparisKalemleri).insert(
            SiparisKalemleriCompanion(
              siparisLocalId: Value(siparisId),
              urunKodu: Value(item.urunKodu),
              urunAdi: Value(item.urunAdi),
              miktar: Value(item.miktar),
              birimFiyat: Value(item.birimFiyat),
              toplamFiyat: Value(item.miktar * item.birimFiyat),
              syncStatus: Value('pending_insert'),
            ),
          );
        }
      }
      
      return siparisId;
    });
  }
  
  Future<void> updateOrder(int localId, {
    String? musteriAdi,
    double? toplamTutar,
    String? durum,
  }) async {
    await (_db.update(_db.siparisler)
          ..where((tbl) => tbl.localId.equals(localId)))
        .write(
      SiparislerCompanion(
        musteriAdi: musteriAdi != null ? Value(musteriAdi) : Value.absent(),
        toplamTutar: toplamTutar != null ? Value(toplamTutar) : Value.absent(),
        durum: durum != null ? Value(durum) : Value.absent(),
        syncStatus: Value('pending_update'), // Sync gerektiğini işaretle
        lastModified: Value(DateTime.now()),
      ),
    );
  }
  
  Future<void> deleteOrder(int localId) async {
    // Hard delete yerine soft delete (sync için)
    await (_db.update(_db.siparisler)
          ..where((tbl) => tbl.localId.equals(localId)))
        .write(
      SiparislerCompanion(
        syncStatus: Value('pending_delete'),
        lastModified: Value(DateTime.now()),
      ),
    );
  }
}
```

## 🎨 UI - Senkronizasyon Durumu Gösterimi

### Pending Count Widget

```dart
class SyncStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.watch(syncServiceProvider);
    final connectionState = ref.watch(connectivityStateProvider);
    
    return FutureBuilder<int>(
      future: syncService.getPendingCount(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data ?? 0;
        final isOnline = connectionState.value == ConnectionState.online;
        
        if (pendingCount == 0) {
          return SizedBox.shrink();
        }
        
        return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOnline ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOnline ? Colors.blue : Colors.orange,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isOnline ? Icons.sync : Icons.sync_disabled,
                color: isOnline ? Colors.blue : Colors.orange,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pendingCount kayıt senkronize edilmeyi bekliyor',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (!isOnline)
                      Text(
                        'İnternet bağlantısı olmadan çalışıyorsunuz',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              if (isOnline)
                ElevatedButton.icon(
                  onPressed: () => syncService.triggerSync(),
                  icon: Icon(Icons.sync, size: 16),
                  label: Text('Senkronize Et'),
                ),
            ],
          ),
        );
      },
    );
  }
}
```

## 🧪 Test Senaryoları

### 1. Offline Kayıt Testi

```dart
test('Offline kayıt oluşturma', () async {
  final db = AppDatabase();
  final repo = OrderRepository(db);
  
  // İnternet olmadan kayıt oluştur
  final orderId = await repo.createOrder(
    musteriAdi: 'Test Customer',
    toplamTutar: 1000.0,
  );
  
  // Sync durumunu kontrol et
  final order = await (db.select(db.siparisler)
        ..where((tbl) => tbl.localId.equals(orderId)))
      .getSingle();
  
  expect(order.syncStatus, 'pending_insert');
  expect(order.remoteId, isNull);
});
```

### 2. Sync Testi

```dart
test('Parent-child sync sırası', () async {
  final mockDio = MockDio();
  final db = AppDatabase();
  
  // Mock responses
  when(mockDio.post('/api/siparisler', data: anyNamed('data')))
      .thenAnswer((_) async => Response(
            data: {'id': 'remote-123'},
            statusCode: 201,
            requestOptions: RequestOptions(),
          ));
  
  final syncService = SyncService(database: db, dio: mockDio);
  final result = await syncService.syncAll();
  
  expect(result.success, true);
  expect(result.siparisCount, greaterThan(0));
});
```

## ⚡ Performans Optimizasyonları

### Indexed Columns

```dart
@override
List<Index> get indexes => [
  Index('idx_sync_status', [syncStatus]),
  Index('idx_remote_id', [remoteId]),
  Index('idx_last_modified', [lastModified]),
];
```

### Batch Insert

```dart
Future<void> batchInsertOrders(List<OrderData> orders) async {
  await _db.batch((batch) {
    for (final order in orders) {
      batch.insert(_db.siparisler, SiparislerCompanion(...));
    }
  });
}
```

## 🔐 Güvenlik

### Encrypted Database

```dart
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

NativeDatabase _openConnection() {
  return NativeDatabase.createInBackground(
    file,
    setup: (rawDb) {
      rawDb.execute("PRAGMA key = 'your-encryption-key'");
    },
  );
}
```

## 📊 İzleme & Logging

```dart
class SyncLogger {
  static void logSync(String message) {
    print('[SYNC] ${DateTime.now()}: $message');
    // Firebase Analytics, Sentry, etc.
  }
}
```

## 🎯 Best Practices Özeti

✅ **Her zaman transaction kullan** (atomic operations)  
✅ **Error handling yap** (try-catch + logging)  
✅ **Progress göster** (kullanıcı deneyimi)  
✅ **Selective sync** (sadece değişenleri)  
✅ **Conflict resolution stratejisi** (server wins)  
✅ **Retry mechanism** (exponential backoff)  
✅ **Background sync** (WorkManager)  
✅ **Index kullan** (performans)  
✅ **Test yaz** (unit + integration)  
✅ **Monitor et** (analytics + crash reporting)
