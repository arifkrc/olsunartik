import 'package:dio/dio.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../datasources/product_remote_datasource.dart';

/// Product Repository Implementation
/// IProductRepository interface'ini implement eder
class ProductRepositoryImpl implements IProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final dtoList = await _remoteDataSource.getAllProducts();
      return dtoList.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  @override
  Future<List<Product>> getAllRawProducts() async {
    try {
      final dtoList = await _remoteDataSource.getAllRawProducts();
      return dtoList.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final dtoList = await _remoteDataSource.searchProducts(query);
      return dtoList.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  List<Product> _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw Exception('Bağlantı zaman aşımına uğradı');
    } else if (e.type == DioExceptionType.connectionError) {
      throw Exception('Sunucuya bağlanılamıyor. Backend çalışıyor mu?');
    } else if (e.response?.statusCode == 404) {
      return [];
    } else if (e.response?.statusCode == 500) {
      throw Exception('Sunucu hatası');
    } else {
      throw Exception(e.message ?? 'Ürünler getirilemedi');
    }
  }
}

