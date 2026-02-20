import 'package:dio/dio.dart';
import '../models/analytics_range_dto.dart';

class AnalyticsRemoteDataSource {
  final Dio _dio;

  AnalyticsRemoteDataSource(this._dio);

  Future<AnalyticsRangeDto> getRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    String dateStr(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final response = await _dio.get(
      '/api/v1/analytics/range',
      queryParameters: {
        'startDate': dateStr(startDate),
        'endDate': dateStr(endDate),
      },
    );

    return AnalyticsRangeDto.fromJson(response.data as Map<String, dynamic>);
  }
}
