import '../entities/fire_search_result.dart';

/// Fire Search Repository Interface
/// Fire arama operasyonları için contract tanımı
abstract class IFireSearchRepository {
  /// Fire kayıtlarını ara
  ///
  /// [productCode] ürün kodu filtresi (opsiyonel)
  /// [startDate] başlangıç tarihi
  /// [endDate] bitiş tarihi
  ///
  /// Returns list of FireSearchResult entities
  Future<List<FireSearchResult>> searchFireRecords({
    String? productCode,
    String? section,
    required DateTime startDate,
    required DateTime endDate,
  });
}
