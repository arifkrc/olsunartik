import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/quality_search_result.dart';

part 'quality_search_providers.g.dart';

@riverpod
class QualityApprovalSearchState extends _$QualityApprovalSearchState {
  @override
  FutureOr<List<QualityApprovalSearchResult>> build() {
    return [];
  }

  Future<void> searchQualityRecords({
    String? productCode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncValue.loading();

    // Mock Data Simulation
    await Future.delayed(const Duration(milliseconds: 600));

    // Sample data
    final mockData = [
      QualityApprovalSearchResult(
        id: 'qa_001',
        productCode: '6312011',
        productName: 'SAF B9',

        operator: 'Ahmet Yılmaz',
        shift: 'Vardiya 1',
        approvalStatus: 'Onay',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      QualityApprovalSearchResult(
        id: 'qa_002',
        productCode: '6312011',
        productName: 'SAF B9',

        operator: 'Mehmet Demir',
        shift: 'Vardiya 2',
        approvalStatus: 'Ret',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      QualityApprovalSearchResult(
        id: 'qa_003',
        productCode: '856985',
        productName: 'Tork Mili',

        operator: 'Ayşe Kaya',
        shift: 'Vardiya 1',
        approvalStatus: 'Onay',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      QualityApprovalSearchResult(
        id: 'qa_004',
        productCode: '856985',
        productName: 'Tork Mili',

        operator: 'Fatma Çelik',
        shift: 'Vardiya 3',
        approvalStatus: 'Şartlı Kabul',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      QualityApprovalSearchResult(
        id: 'qa_005',
        productCode: '6312012',
        productName: 'Şanzıman Dişlisi',

        operator: 'Mustafa Şahin',
        shift: 'Vardiya 2',
        approvalStatus: 'Onay',
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
      QualityApprovalSearchResult(
        id: 'qa_006',
        productCode: '123456',
        productName: 'Fren Diski',

        operator: 'Ali Vural',
        shift: 'Vardiya 1',
        approvalStatus: 'Ret',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    var filteredData = mockData;

    // Filter by Product Code
    if (productCode != null && productCode.isNotEmpty) {
      filteredData = filteredData
          .where((item) => item.productCode.contains(productCode))
          .toList();
    }

    state = AsyncValue.data(filteredData);
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
