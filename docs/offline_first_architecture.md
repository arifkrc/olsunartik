# Offline-First Senkronizasyon Mimarisi

## 🎯 Temel Prensipler

### 1. Veri Akış Mantığı

```
┌─────────────────────────────────────────────────────────────┐
│                    USER ACTION (OFFLINE)                     │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│         LOCAL DATABASE (Drift/SQLite)                        │
│  • sync_status = 'pending_insert/update/delete'              │
│  • last_modified = DateTime.now()                            │
│  • remote_id = null (if new)                                 │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │  Internet Geldi mi?   │
                    └───────┬───────────────┘
                            │
                ┌───────────┴───────────┐
                │                       │
                ▼                       ▼
            HAYIR                     EVET
      ┌──────────────┐        ┌──────────────┐
      │ Bekle/Göster │        │ SYNC BAŞLAT  │
      └──────────────┘        └──────┬───────┘
                                     │
                ┌────────────────────┴────────────────────┐
                │                                         │
                ▼                                         ▼
    ┌──────────────────────┐              ┌──────────────────────┐
    │ 1. PARENT SYNC       │              │ Conflict Resolution  │
    │ (Sipariş)            │              │ (server kazanır)     │
    │ - pending kayıtlar   │              └──────────────────────┘
    │ - server'a POST      │
    │ - remote_id al       │
    └──────┬───────────────┘
           │
           ▼
    ┌──────────────────────┐
    │ 2. LOCAL UPDATE      │
    │ - remote_id kaydet   │
    │ - child'ları güncelle│
    │ - status = 'synced'  │
    └──────┬───────────────┘
           │
           ▼
    ┌──────────────────────┐
    │ 3. CHILD SYNC        │
    │ (SiparişKalemi)      │
    │ - parent remote_id   │
    │ - server'a POST      │
    │ - status = 'synced'  │
    └──────────────────────┘
```

### 2. Senkronizasyon Stratejisi

#### **Dört Temel Durum:**

| Sync Status | Açıklama | Aksiyon |
|-------------|----------|---------|
| `synced` | Sunucu ile senkron | Hiçbir şey yapma |
| `pending_insert` | Yeni kayıt, henüz gönderilmedi | POST isteği at |
| `pending_update` | Güncellenmiş kayıt | PUT isteği at |
| `pending_delete` | Silinmiş kayıt | DELETE isteği at |

#### **Parent-Child Senkronizasyon Sırası:**

1. **Önce Parent'lar** (Sipariş)
   - `sync_status = 'pending_insert'` olanları filtrele
   - Sırayla sunucuya POST et
   - Dönen `remote_id`'yi local DB'de güncelle
   
2. **Sonra Child'lar** (SiparişKalemi)
   - Parent'ın `remote_id`'si ile eşleştir
   - Sunucuya gönder
   - Statüsünü `synced` yap

## 📊 Tablo Yapısı

### Ortak Sync Alanları

Her tabloda olması gerekenler:

```dart
// Sync tracking mixin
mixin SyncMixin {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending_insert'))();
  DateTimeColumn get lastModified => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

**Sync Status Değerleri:**
- `synced`: Senkronize edilmiş
- `pending_insert`: Henüz eklenmedi (yeni kayıt)
- `pending_update`: Güncellendi ama senkronize edilmedi
- `pending_delete`: Silinmiş ama sunucudan henüz kaldırılmadı

## 🔄 Çakışma Çözümü (Conflict Resolution)

### Strateji: **Server Wins** (Sunucu Kazanır)

```dart
Future<void> resolveConflict(LocalData local, RemoteData remote) async {
  // Sunucudaki versiyon daha yeniyse
  if (remote.lastModified.isAfter(local.lastModified)) {
    // Local'i üzerine yaz
    await updateLocalFromRemote(remote);
  } else {
    // Local versiyon yeniyse, sync yap
    await syncToServer(local);
  }
}
```

## 📱 Connectivity Monitoring

### İnternet Durumu Dinleme

```dart
class ConnectivityService {
  final _connectivity = Connectivity();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  
  Stream<bool> get connectionStream => _connectionController.stream;
  bool _isConnected = false;
  
  void initialize() {
    // İlk durumu kontrol et
    _checkConnectivity();
    
    // Değişiklikleri dinle
    _connectivity.onConnectivityChanged.listen((result) {
      _checkConnectivity();
    });
  }
  
  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    _connectionController.add(_isConnected);
    
    // İnternet yeni geldiyse sync tetikle
    if (!wasConnected && _isConnected) {
      SyncService().triggerSync();
    }
  }
  
  bool get isConnected => _isConnected;
}
```

## 🚀 Optimizasyonlar

### Batch Processing
```dart
// Tek tek değil, toplu gönder
Future<void> syncInBatch(List<SyncableEntity> items) async {
  const batchSize = 50;
  for (var i = 0; i < items.length; i += batchSize) {
    final batch = items.skip(i).take(batchSize).toList();
    await _sendBatch(batch);
  }
}
```

### Retry Mechanism
```dart
Future<T> retrySync<T>(Future<T> Function() operation, {int maxRetries = 3}) async {
  for (var i = 0; i < maxRetries; i++) {
    try {
      return await operation();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 2 << i)); // Exponential backoff
    }
  }
  throw Exception('Max retries exceeded');
}
```

## 📈 Senkronizasyon Metrikleri

```dart
class SyncMetrics {
  int totalPending = 0;
  int totalSynced = 0;
  int failedCount = 0;
  DateTime? lastSyncTime;
  Duration? syncDuration;
}
```

## ⚠️ Hata Senaryoları

| Senaryo | Çözüm |
|---------|-------|
| Parent gönderildi ama remote_id alınamadı | Transaction rollback, tekrar dene |
| Child gönderilirken parent remote_id yok | Skip, parent sync bekle |
| Sunucu 500 döndü | Exponential backoff ile retry |
| İnternet senkronizasyon sırasında kesildi | Transaction rollback, status koru |

## 🎓 Best Practices

1. **Transaction Kullan**: Parent-child senkronizasyonu atomic olmalı
2. **Queue Sistemi**: Senkronizasyon queue'da beklesin, kullanıcı beklemeden devam etsin
3. **Progress Göster**: Kullanıcıya "3/10 kayıt senkronize edildi" gibi feedback ver
4. **Selective Sync**: Tüm tabloları değil, sadece değişenleri senkronize et
5. **Timestamp Comparison**: Server ve client timestamp'lerini karşılaştır

## 🛡️ Güvenlik & Performans

- **Token Refresh**: Auth token expire olursa otomatik yenile
- **Compression**: Büyük payloadlar için gzip kullan
- **Background Sync**: `WorkManager` (Android) / `BackgroundTasks` (iOS) ile arka planda sync
- **Partial Sync**: Sadece son X gündeki değişiklikleri senkronize et
