import '../entities/product.dart';

/// Product Repository Interface
/// Product data operations için contract tanımı
abstract class IProductRepository {
  /// Tüm ürünleri getirir (client-side filtreleme için)
  Future<List<Product>> getAllProducts();

  /// Ham ürünleri getirir (client-side filtreleme için)
  Future<List<Product>> getAllRawProducts();

  /// Ürün arama (geriye dönük uyumluluk)
  Future<List<Product>> searchProducts(String query);
}

