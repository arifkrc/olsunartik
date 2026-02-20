import '../entities/product.dart';

/// Product Repository Interface
/// Product data operations için contract tanımı
abstract class IProductRepository {
  /// Tüm ürünleri getirir (client-side filtreleme için)
  Future<List<Product>> getAllProducts();

  /// Ürün arama (geriye dönük uyumluluk)
  Future<List<Product>> searchProducts(String query);
}

