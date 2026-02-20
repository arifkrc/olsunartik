import 'package:dio/dio.dart';
import '../../domain/entities/fire_search_result.dart';
import '../../domain/repositories/i_fire_search_repository.dart';
import '../datasources/fire_search_remote_datasource.dart';

/// Fire Search Repository Implementation
/// IFireSearchRepository interface'ini implement eder
class FireSearchRepositoryImpl implements IFireSearchRepository {
  final FireSearchRemoteDataSource _remoteDataSource;

  FireSearchRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<FireSearchResult>> searchFireRecords({
    String? productCode,
    String? section,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final dtoList = await _remoteDataSource.searchFireRecords(
        productCode: productCode,
        section: section,
        startDate: startDate,
        endDate: endDate,
      );
      return dtoList.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      // Network hatalarını handle et
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Bağlantı zaman aşımına uğradı');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('İnternet bağlantısı yok');
      } else if (e.response?.statusCode == 404) {
        // 404 durumunda boş liste döndür
        return [];
      } else if (e.response?.statusCode == 500) {
        throw Exception('Sunucu hatası');
      } else {
        throw Exception(e.message ?? 'Fire kayıtları getirilemedi');
      }
    } catch (e) {
      throw Exception('Beklenmeyen hata: $e');
    }
  }
}
