import 'package:dio/dio.dart';
import '../models/saf_b9_counter_entry_dto.dart';

class SafB9CounterRemoteDataSource {
  final Dio _dio;

  SafB9CounterRemoteDataSource(this._dio);

  Future<String> create(SAFBRequestDto request) async {
    try {
      final response = await _dio.post('/api/SAFB', data: request.toJson());
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
}
