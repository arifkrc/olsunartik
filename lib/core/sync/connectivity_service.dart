import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'sync_service.dart';
import '../providers/app_providers.dart';
import '../utils/app_logger.dart';

part 'connectivity_service.g.dart';

/// İnternet bağlantısını izleyen ve otomatik senkronizasyon tetikleyen servis
class ConnectivityService {
  final Connectivity _connectivity;
  final SyncService _syncService;
  final Dio _dio;

  final StreamController<ConnectionState> _stateController =
      StreamController<ConnectionState>.broadcast();

  Stream<ConnectionState> get stateStream => _stateController.stream;

  ConnectionState _currentState = ConnectionState.unknown;
  ConnectionState get currentState => _currentState;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncDebounceTimer;

  ConnectivityService({
    required Connectivity connectivity,
    required SyncService syncService,
    required Dio dio,
  }) : _connectivity = connectivity,
       _syncService = syncService,
       _dio = dio;

  // ============================================================================
  // BAŞLATMA
  // ============================================================================

  Future<void> initialize() async {
    AppLogger.network('Connectivity service başlatılıyor...');

    // İlk durumu kontrol et
    await _checkInitialConnectivity();

    // Connectivity değişikliklerini dinle
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        AppLogger.error(
          'Connectivity error',
          error: error,
          tag: 'ConnectivityService',
        );
      },
    );

    AppLogger.success('Connectivity service hazır');
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _onConnectivityChanged(results);
    } catch (e) {
      AppLogger.warning(
        'İlk connectivity kontrolü başarısız',
        error: e,
        tag: 'ConnectivityService',
      );
      _updateState(ConnectionState.offline);
    }
  }

  // ============================================================================
  // CONNECTIVITY DEĞİŞİKLİKLERİNİ DİNLE
  // ============================================================================

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    AppLogger.network('Connectivity değişti: $results');

    // None varsa offline
    if (results.contains(ConnectivityResult.none)) {
      _updateState(ConnectionState.offline);
      return;
    }

    // WiFi veya Mobile varsa, gerçek internet kontrolü yap
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile)) {
      await _verifyInternetAccess();
    } else {
      // Bluetooth, Ethernet vs.
      _updateState(ConnectionState.limited);
    }
  }

  /// Gerçek internet erişimi kontrolü (ping-like)
  Future<void> _verifyInternetAccess() async {
    AppLogger.debug(
      'İnternet erişimi doğrulanıyor...',
      tag: 'ConnectivityService',
    );

    try {
      // Backend'e hafif bir health check isteği
      final response = await _dio.get(
        'health',
        options: Options(
          sendTimeout: Duration(seconds: 5),
          receiveTimeout: Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        AppLogger.success('İnternet erişimi doğrulandı');
        _updateState(ConnectionState.online);

        // Otomatik sync tetikle (debounced)
        _debouncedSync();
      } else {
        AppLogger.warning(
          'Server yanıt verdi ama durum kodu: ${response.statusCode}',
          tag: 'ConnectivityService',
        );
        _updateState(ConnectionState.limited);
      }
    } on DioException catch (e) {
      AppLogger.warning(
        'İnternet doğrulaması başarısız: ${e.type}',
        tag: 'ConnectivityService',
      );

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        _updateState(ConnectionState.limited);
      } else {
        // Server error vs. - bağlantı var ama sorunlu
        _updateState(ConnectionState.limited);
      }
    } catch (e) {
      AppLogger.error(
        'İnternet doğrulama hatası',
        error: e,
        tag: 'ConnectivityService',
      );
      _updateState(ConnectionState.offline);
    }
  }

  // ============================================================================
  // STATE YÖNETİMİ
  // ============================================================================

  void _updateState(ConnectionState newState) {
    final wasOnline = _currentState == ConnectionState.online;
    final isOnline = newState == ConnectionState.online;

    if (_currentState != newState) {
      AppLogger.sync('Bağlantı durumu: $_currentState → $newState');
      _currentState = newState;
      _stateController.add(newState);

      // Offline'dan online'a geçiş → Sync tetikle
      if (!wasOnline && isOnline) {
        AppLogger.info('İnternet geldi! Senkronizasyon tetikleniyor...');
        _debouncedSync();
      }
    }
  }

  /// Debounced sync - Çok hızlı tetiklenmeleri engelle
  void _debouncedSync() {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(Duration(seconds: 2), () {
      _syncService.triggerSync();
    });
  }

  // ============================================================================
  // MANUEL KONTROLLER
  // ============================================================================

  /// Manuel connectivity kontrolü (kullanıcı "Yenile" butonuna bastığında)
  Future<void> refresh() async {
    AppLogger.sync('Manuel connectivity kontrolü...');
    await _checkInitialConnectivity();
  }

  /// Şu anda online mı?
  bool get isOnline => _currentState == ConnectionState.online;

  /// Şu anda offline mı?
  bool get isOffline => _currentState == ConnectionState.offline;

  // ============================================================================
  // TEMIZLEME
  // ============================================================================

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncDebounceTimer?.cancel();
    _stateController.close();
    AppLogger.info('Connectivity service durduruldu');
  }
}

// ============================================================================
// CONNECTION STATE ENUM
// ============================================================================

enum ConnectionState {
  unknown, // İlk durum, henüz kontrol edilmedi
  offline, // Hiç bağlantı yok
  limited, // Bağlantı var ama internet yok (veya server erişilemiyor)
  online, // Tam erişim var
}

// ============================================================================
// RIVERPOD PROVIDER
// ============================================================================

@riverpod
ConnectivityService connectivityService(Ref ref) {
  final connectivity = Connectivity();
  final syncService = ref.watch(syncServiceProvider);
  final dio = ref.watch(dioProvider);

  final service = ConnectivityService(
    connectivity: connectivity,
    syncService: syncService,
    dio: dio,
  );

  // Auto-initialize
  service.initialize();

  // Auto-dispose
  ref.onDispose(() => service.dispose());

  return service;
}

/// Connectivity durumunu dinleyen provider
@riverpod
Stream<ConnectionState> connectivityState(Ref ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.stateStream;
}

// ============================================================================
// UI WIDGET - Connectivity Banner
// ============================================================================

/*
KULLANIM ÖRNEĞİ:

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectivityStateProvider);
    
    return Scaffold(
      body: Column(
        children: [
          // Bağlantı durumu banner'ı
          connectionState.when(
            data: (state) {
              if (state == ConnectionState.offline) {
                return Container(
                  color: Colors.red,
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Offline mod - Değişiklikler kaydedilecek',
                           style: TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              } else if (state == ConnectionState.limited) {
                return Container(
                  color: Colors.orange,
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(Icons.signal_wifi_statusbar_null, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Bağlantı zayıf',
                           style: TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              }
              return SizedBox.shrink(); // Online ise banner gösterme
            },
            loading: () => SizedBox.shrink(),
            error: (_, __) => SizedBox.shrink(),
          ),
          
          Expanded(
            child: YourContent(),
          ),
        ],
      ),
    );
  }
}
*/
