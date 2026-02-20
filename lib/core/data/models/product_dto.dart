import '../../domain/entities/product.dart';

/// Product DTO - Data Transfer Object
/// API response'larını map etmek için kullanılır
class ProductDto extends Product {
  const ProductDto({
    super.id,
    required super.urunKodu,
    required super.urunAdi,
    required super.urunTuru,
  });

  /// JSON'dan ProductDto oluştur
  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int?,
      urunKodu: json['urunKodu'] as String,
      urunAdi: json['urunAdi'] as String,
      urunTuru: json['urunTuru'] as String,
    );
  }

  /// ProductDto'yu JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'urunKodu': urunKodu,
      'urunAdi': urunAdi,
      'urunTuru': urunTuru,
    };
  }

  /// DTO'dan Entity'ye dönüşüm
  Product toEntity() {
    return Product(
      id: id,
      urunKodu: urunKodu,
      urunAdi: urunAdi,
      urunTuru: urunTuru,
    );
  }
}
