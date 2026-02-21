import 'package:dio/dio.dart';
import '../models/fire_search_result_dto.dart';

/// Fire Search Remote DataSource
/// Backend API'den fire kayıtlarını çeker
class FireSearchRemoteDataSource {
  final Dio _dio;

  FireSearchRemoteDataSource(this._dio);

  /// Fire kayıtlarını ara
  ///
  /// [productCode] ürün kodu (opsiyonel)
  /// [startDate] başlangıç tarihi
  /// [endDate] bitiş tarihi
  ///
  /// Returns list of FireSearchResultDto
  /// Throws [DioException] on network errors
  Future<List<FireSearchResultDto>> searchFireRecords({
    String? productCode,
    String? section,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      if (productCode != null && productCode.isNotEmpty) {
        queryParams['productCode'] = productCode;
      }

      if (section != null && section.isNotEmpty) {
        queryParams['zone'] = section;
      }

      final response = await _dio.get(
        'forms/wastage/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Result wrapper pattern kontrolü
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> resultList = data['data'] as List<dynamic>;
          return resultList
              .map(
                (json) =>
                    FireSearchResultDto.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            error: data['message'] ?? 'Fire kayıtları getirilemedi',
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
        requestOptions: RequestOptions(path: 'forms/wastage/search'),
        error: e.toString(),
        type: DioExceptionType.unknown,
      );
    }
  }
}
