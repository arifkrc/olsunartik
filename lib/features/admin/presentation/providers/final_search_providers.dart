import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/final_search_result.dart';

part 'final_search_providers.g.dart';

@riverpod
class FinalSearchState extends _$FinalSearchState {
  @override
  FutureOr<List<FinalSearchResult>> build() {
    return [];
  }

  Future<void> searchFinalRecords({
    String? productCode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncValue.loading();

    // Mock Data Simulation
    await Future.delayed(const Duration(milliseconds: 600));

    // Sample data with diversity
    final mockData = [
      FinalSearchResult(
        id: 'final_001',
        productCode: '6312011',
        productName: 'SAF B9',
        customer: 'Mercedes-Benz',
        productionQuantity: 1200,
        rejectQuantity: 5,
        personnel: 'Ahmet Yılmaz',
        date: DateTime.now().subtract(const Duration(days: 1)),
        batchNo: '26F025A',
      ),
      FinalSearchResult(
        id: 'final_002',
        productCode: '6312011',
        productName: 'SAF B9',
        customer: 'BPW',
        productionQuantity: 850,
        rejectQuantity: 0,
        personnel: 'Mehmet Demir',
        date: DateTime.now().subtract(const Duration(days: 2)),
        batchNo: '26F022B',
      ),
      FinalSearchResult(
        id: 'final_003',
        productCode: '856985',
        productName: 'Tork Mili',
        customer: 'Volvo',
        productionQuantity: 500,
        rejectQuantity: 12,
        personnel: 'Ayşe Kaya',
        date: DateTime.now().subtract(const Duration(days: 1)),
        batchNo: '26F030A',
      ),
      FinalSearchResult(
        id: 'final_004',
        productCode: '856985',
        productName: 'Tork Mili',
        customer: 'Scania',
        productionQuantity: 620,
        rejectQuantity: 2,
        personnel: 'Fatma Çelik',
        date: DateTime.now().subtract(const Duration(days: 3)),
        batchNo: '26F028B',
      ),
      FinalSearchResult(
        id: 'final_005',
        productCode: '6312012',
        productName: 'Şanzıman Dişlisi',
        customer: 'ZF',
        productionQuantity: 300,
        rejectQuantity: 8,
        personnel: 'Mustafa Şahin',
        date: DateTime.now().subtract(const Duration(days: 4)),
        batchNo: '26F024T',
      ),
      FinalSearchResult(
        id: 'final_006',
        productCode: '123456',
        productName: 'Fren Diski',
        customer: 'MAN',
        productionQuantity: 450,
        rejectQuantity: 0,
        personnel: 'Ali Vural',
        date: DateTime.now().subtract(const Duration(days: 2)),
        batchNo: '26F050K',
      ),
    ];

    var filteredData = mockData;

    // Filter by Product Code
    if (productCode != null && productCode.isNotEmpty) {
      filteredData = filteredData
          .where((item) => item.productCode.contains(productCode))
          .toList();
    }

    // Filter by Date (simple logic for mock)
    // In real app, apply date range filtering
    if (startDate.isAfter(DateTime(2020))) {
      // Mock date filtering logic if needed, but for now returned all matches
    }

    state = AsyncValue.data(filteredData);
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
