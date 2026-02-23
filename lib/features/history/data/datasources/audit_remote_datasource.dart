import 'package:dio/dio.dart';
import '../models/audit_action_dto.dart';

class AuditRemoteDataSource {
  final Dio _dio;

  AuditRemoteDataSource(this._dio);

  Future<List<AuditActionDto>> getMyActions({
    required int pageNumber,
    required int pageSize,
    String? varlikTipi,
  }) async {
    final response = await _dio.get(
      '/audit/my-actions',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (varlikTipi != null && varlikTipi != 'Tümü') 'varlikTipi': varlikTipi,
      },
    );

    if (response.data is List) {
      return (response.data as List)
          .map((json) => AuditActionDto.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
