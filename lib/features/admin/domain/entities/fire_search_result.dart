/// Fire Search Result entity
/// Fire kayıtlarının arama sonuçlarını temsil eder
class FireSearchResult {
  final String id;
  final String productCode;
  final String productName;
  final String productType;
  final int productionQuantity;
  final int scrapQuantity;
  final String scrapReason;
  final String errorCode;
  final DateTime date;
  final String? machine;
  final String? zone;
  final String? batchNo;

  const FireSearchResult({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.productType,
    required this.productionQuantity,
    required this.scrapQuantity,
    required this.scrapReason,
    required this.errorCode,
    required this.date,
    this.machine,
    this.zone,
    this.batchNo,
  });

  /// Fire oranını hesapla (%)
  double get scrapRate {
    if (productionQuantity == 0) return 0.0;
    return (scrapQuantity / productionQuantity) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FireSearchResult &&
        other.id == id &&
        other.productCode == productCode &&
        other.date == date;
  }

  @override
  int get hashCode => id.hashCode ^ productCode.hashCode ^ date.hashCode;

  @override
  String toString() =>
      'FireSearchResult(id: $id, productCode: $productCode, scrapQuantity: $scrapQuantity)';
}
