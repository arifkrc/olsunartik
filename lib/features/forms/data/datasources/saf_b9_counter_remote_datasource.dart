import '../../../../core/models/paged_result.dart';
import 'package:dio/dio.dart';
import '../models/saf_b9_counter_entry_dto.dart';

class SafB9CounterRemoteDataSource {
  final Dio _dio;

  SafB9CounterRemoteDataSource(this._dio);

  Future<PagedResult<SAFBResponseDto>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
    int? vardiyaId,
  }) async {
    final response = await _dio.get(
      'safb9',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (startDate != null) 'startDate': startDate.toUtc().toIso8601String(),
        if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
        if (vardiyaId != null) 'vardiyaId': vardiyaId,
      },
    );
    if (response.data['success'] == true) {
      return PagedResult<SAFBResponseDto>.fromJson(
        response.data['data'],
        (j) => SAFBResponseDto.fromJson(j),
      );
    }
    throw Exception(response.data['message'] ?? 'Veriler alınamadı');
  }

  Future<String> create(SAFBRequestDto request) async {
    try {
      final response = await _dio.post('SAFB', data: request.toJson());
      final data = response.data;

      if (data['success'] == true) {
        return data['message'] as String? ?? 'Kayıt başarıyla oluşturuldu';
      } else {
        throw Exception(data['message'] ?? 'Kayıt oluşturulamadı');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        final message = errorData?['message'] ??
            (errorData?['errors'] as List?)?.first ??
            'Geçersiz istek';
        throw Exception(message);
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Sunucuya bağlanılamıyor. Backend çalışıyor mu?');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Bağlantı zaman aşımına uğradı');
      }
      throw Exception(e.message ?? 'Bilinmeyen hata');
    }
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('safb9/$id', data: data);
      final respData = response.data;
      if (respData['success'] == false) {
        throw Exception(respData['message'] ?? 'Güncelleme hatası');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        final message = errorData?['message'] ??
            (errorData?['errors'] as List?)?.first ??
            'Geçersiz istek';
        throw Exception(message);
      }
      throw Exception(e.message ?? 'Bilinmeyen hata');
    }
  }

  Future<void> delete(int id) async {
    await _dio.delete('safb9/$id');
  }
}
