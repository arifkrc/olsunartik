import '../entities/fire_search_result.dart';
import '../repositories/i_fire_search_repository.dart';

/// Search Fire Records UseCase
/// Fire kayıtlarını arama business logic'ini içerir
class SearchFireRecordsUseCase {
  final IFireSearchRepository _repository;

  SearchFireRecordsUseCase(this._repository);

  /// Fire kayıtlarını ara
  ///
  /// [productCode] ürün kodu filtresi (opsiyonel)
  /// [startDate] başlangıç tarihi
  /// [endDate] bitiş tarihi
  ///
  /// Returns list of FireSearchResult entities
  Future<List<FireSearchResult>> call({
    String? productCode,
    String? section,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Tarih validasyonu
    if (startDate.isAfter(endDate)) {
      throw Exception('Başlangıç tarihi bitiş tarihinden sonra olamaz');
    }

    // Maksimum 90 gün kontrolü
    final difference = endDate.difference(startDate).inDays;
    if (difference > 90) {
      throw Exception('Maksimum 90 günlük arama yapılabilir');
    }

    return await _repository.searchFireRecords(
      productCode: productCode?.trim(),
      section: section,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
