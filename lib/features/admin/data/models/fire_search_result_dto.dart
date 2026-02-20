import '../../domain/entities/fire_search_result.dart';

/// Fire Search Result DTO
/// API response mapping için kullanılır
class FireSearchResultDto extends FireSearchResult {
  const FireSearchResultDto({
    required super.id,
    required super.productCode,
    required super.productName,
    required super.productType,
    required super.productionQuantity,
    required super.scrapQuantity,
    required super.scrapReason,
    required super.errorCode,
    required super.date,
    super.machine,
    super.zone,
    super.batchNo,
  });

  /// JSON'dan DTO oluştur
  factory FireSearchResultDto.fromJson(Map<String, dynamic> json) {
    return FireSearchResultDto(
      id: json['id'] as String,
      productCode: json['productCode'] as String,
      productName: json['productName'] as String,
      productType: json['productType'] as String,
      productionQuantity: json['productionQuantity'] as int,
      scrapQuantity: json['scrapQuantity'] as int,
      scrapReason: json['scrapReason'] as String,
      errorCode: json['errorCode'] as String,
      date: DateTime.parse(json['date'] as String),
      machine: json['machine'] as String?,
      zone: json['zone'] as String?,
      batchNo: json['batchNo'] as String?,
    );
  }

  /// DTO'yu JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productCode': productCode,
      'productName': productName,
      'productType': productType,
      'productionQuantity': productionQuantity,
      'scrapQuantity': scrapQuantity,
      'scrapReason': scrapReason,
      'errorCode': errorCode,
      'date': date.toIso8601String(),
      'machine': machine,
      'zone': zone,
      'batchNo': batchNo,
    };
  }

  /// DTO'dan Entity'ye dönüşüm
  FireSearchResult toEntity() {
    return FireSearchResult(
      id: id,
      productCode: productCode,
      productName: productName,
      productType: productType,
      productionQuantity: productionQuantity,
      scrapQuantity: scrapQuantity,
      scrapReason: scrapReason,
      errorCode: errorCode,
      date: date,
      machine: machine,
      zone: zone,
      batchNo: batchNo,
    );
  }
}
