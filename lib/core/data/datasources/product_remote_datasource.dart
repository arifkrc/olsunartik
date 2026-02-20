import 'package:dio/dio.dart';
import '../models/product_dto.dart';

/// Product Remote DataSource
/// Backend API'den ürün verilerini çeker
class ProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSource(this._dio);

  /// Tüm ürün listesini getirir — client-side filtreleme yapılacak
  ///
  /// Endpoint: GET /api/lookup/urunler
  /// Response: { "data": [...], "success": true }
  Future<List<ProductDto>> getAllProducts() async {
    try {
      final response = await _dio.get('/api/lookup/urunler');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> productList = data['data'] as List<dynamic>;
          return productList
              .map((json) => ProductDto.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            error: data['message'] ?? 'Ürünler getirilemedi',
            response: response,
            type: DioExceptionType.badResponse,
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/lookup/urunler'),
        error: e.toString(),
        type: DioExceptionType.unknown,
      );
    }
  }

  /// Eski API — artık getAllProducts kullanılıyor (geriye dönük uyumluluk için tutuldu)
  Future<List<ProductDto>> searchProducts(String query) async {
    final all = await getAllProducts();
    if (query.isEmpty) return all;
    final lowerQuery = query.toLowerCase();
    return all.where((p) {
      return p.urunKodu.toLowerCase().contains(lowerQuery) ||
          p.urunAdi.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
