import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/fire_search_remote_datasource.dart';
import '../../data/repositories/fire_search_repository_impl.dart';
import '../../domain/entities/fire_search_result.dart';
import '../../domain/repositories/i_fire_search_repository.dart';
import '../../domain/usecases/search_fire_records_usecase.dart';

part 'fire_search_providers.g.dart';

/// Fire Search Remote DataSource Provider
@riverpod
FireSearchRemoteDataSource fireSearchRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return FireSearchRemoteDataSource(dio);
}

/// Fire Search Repository Provider
@riverpod
IFireSearchRepository fireSearchRepository(Ref ref) {
  final remoteDataSource = ref.watch(fireSearchRemoteDataSourceProvider);
  return FireSearchRepositoryImpl(remoteDataSource);
}

/// Search Fire Records UseCase Provider
@riverpod
SearchFireRecordsUseCase searchFireRecordsUseCase(Ref ref) {
  final repository = ref.watch(fireSearchRepositoryProvider);
  return SearchFireRecordsUseCase(repository);
}

/// Fire Search State Provider
/// Fire arama sonuçlarını ve state'ini yönetir
@riverpod
class FireSearchState extends _$FireSearchState {
  @override
  FutureOr<List<FireSearchResult>> build() {
    return [];
  }

  // Mock data için flag (backend hazır olunca false yapın)
  static const bool useMockData = true;

  /// Fire kayıtlarını ara
  Future<void> searchFireRecords({
    String? productCode,
    String? section, // Yeni filtre parametresi
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncValue.loading();

    if (useMockData) {
      // Mock data delay (gerçek API gibi)
      await Future.delayed(const Duration(milliseconds: 600));

      // Mock fire records with Updated Zones (D2, D3, FRENBU)
      final mockData = [
        FireSearchResult(
          id: 'fire_001',
          productCode: '6312011',
          productName: 'SAF B9',
          productType: 'Dövme',
          productionQuantity: 254,
          scrapQuantity: 8,
          scrapReason: 'Yüzey Kalitesi Yetersiz',
          errorCode: 'H001',
          date: DateTime.now().subtract(const Duration(days: 2)),
          machine: 'CNC-A',
          zone: 'D2', // Updated
          batchNo: '26F025A',
        ),
        FireSearchResult(
          id: 'fire_002',
          productCode: '6312011',
          productName: 'SAF B9',
          productType: 'Dövme',
          productionQuantity: 180,
          scrapQuantity: 12,
          scrapReason: 'Çatlak',
          errorCode: 'H002',
          date: DateTime.now().subtract(const Duration(days: 5)),
          machine: 'CNC-B',
          zone: 'FRENBU', // Updated
          batchNo: '26F022B',
        ),
        FireSearchResult(
          id: 'fire_003',
          productCode: '6312011',
          productName: 'SAF B9',
          productType: 'Dövme',
          productionQuantity: 320,
          scrapQuantity: 5,
          scrapReason: 'Ölçü Hatası',
          errorCode: 'H003',
          date: DateTime.now().subtract(const Duration(days: 7)),
          machine: 'CNC-A',
          zone: 'D3', // Updated
          batchNo: '26F020A',
        ),
        FireSearchResult(
          id: 'fire_004',
          productCode: '6312012',
          productName: 'Şanzıman Dişlisi',
          productType: 'Talaşlı İmalat',
          productionQuantity: 450,
          scrapQuantity: 15,
          scrapReason: 'Yüzey Pürüzlülüğü',
          errorCode: 'H001',
          date: DateTime.now().subtract(const Duration(days: 3)),
          machine: 'TORNA-5',
          zone: 'D2', // Updated
          batchNo: '26F024T',
        ),
        FireSearchResult(
          id: 'fire_005',
          productCode: '6312012',
          productName: 'Şanzıman Dişlisi',
          productType: 'Talaşlı İmalat',
          productionQuantity: 380,
          scrapQuantity: 22,
          scrapReason: 'Diş Profili Hatası',
          errorCode: 'H004',
          date: DateTime.now().subtract(const Duration(days: 6)),
          machine: 'TORNA-3',
          zone: 'D3', // Updated
          batchNo: '26F021T',
        ),
        FireSearchResult(
          id: 'fire_006',
          productCode: '856985',
          productName: 'Tork Mili',
          productType: 'Dövme',
          productionQuantity: 500,
          scrapQuantity: 45,
          scrapReason: 'Ölçüsel Hata (Çap Düşük)',
          errorCode: 'H012',
          date: DateTime.now().subtract(const Duration(hours: 4)),
          machine: 'CNC-M1',
          zone: 'FRENBU', // Updated
          batchNo: '26F030A',
        ),
        FireSearchResult(
          id: 'fire_007',
          productCode: '856985',
          productName: 'Tork Mili',
          productType: 'Dövme',
          productionQuantity: 480,
          scrapQuantity: 12,
          scrapReason: 'Yüzey Çatlağı',
          errorCode: 'H023',
          date: DateTime.now().subtract(const Duration(days: 1)),
          machine: 'CNC-M2',
          zone: 'D2', // Updated
          batchNo: '26F028B',
        ),
        FireSearchResult(
          id: 'fire_008',
          productCode: '856985',
          productName: 'Tork Mili',
          productType: 'Dövme',
          productionQuantity: 520,
          scrapQuantity: 8,
          scrapReason: 'Montaj Hatası',
          errorCode: 'H045',
          date: DateTime.now().subtract(const Duration(days: 3)),
          machine: 'MONTAJ-1',
          zone: 'FRENBU', // Updated
          batchNo: '26F025C',
        ),
        FireSearchResult(
          id: 'fire_009',
          productCode: '856985',
          productName: 'Tork Mili',
          productType: 'Dövme',
          productionQuantity: 250,
          scrapQuantity: 50,
          scrapReason: 'Hammadde Hatası',
          errorCode: 'H099',
          date: DateTime.now().subtract(const Duration(days: 5)),
          machine: 'CNC-M1',
          zone: 'D3', // Updated
          batchNo: '26F020D',
        ),
      ];

      // Filtreleme Mantığı
      var filteredData = mockData;

      // 1. Ürün Kodu Filtresi
      if (productCode != null && productCode.isNotEmpty) {
        filteredData = filteredData
            .where((item) => item.productCode.contains(productCode))
            .toList();
      }

      // 2. Bölüm (Zone) Filtresi
      if (section != null && section.isNotEmpty && section != 'Tümü') {
        filteredData = filteredData
            .where((item) => item.zone == section)
            .toList();
      }

      state = AsyncValue.data(filteredData);
    } else {
      // Gerçek API çağrısı
      final useCase = ref.read(searchFireRecordsUseCaseProvider);
      state = await AsyncValue.guard(() async {
        return await useCase.call(
          productCode: productCode,
          section: section,
          startDate: startDate,
          endDate: endDate,
        );
      });
    }
  }

  /// Sonuçları temizle
  void clear() {
    state = const AsyncValue.data([]);
  }
}
