import 'package:dio/dio.dart';
import '../models/quality_approval_form_dto.dart';

/// Kalite Onay Remote DataSource
/// POST /api/kaliteonay — kalite onay kaydı oluşturur
class QualityApprovalRemoteDataSource {
  final Dio _dio;

  QualityApprovalRemoteDataSource(this._dio);

  /// Yeni kalite onay kaydı oluşturur, başarı mesajını döndürür
  Future<String> create(KaliteOnayRequestDto request) async {
    try {
      final response = await _dio.post(
        'kaliteonay',
        data: request.toJson(),
      );

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
      final response = await _dio.put('kaliteonay/$id', data: data);
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

  // --- Aşağıdakiler ileride gerekirse kullanılabilir ---

  Future<List<KaliteOnayResponseDto>> getAll() async {
    final response = await _dio.get('kaliteonay');
    final data = response.data;
    if (data['success'] == true && data['data'] != null) {
      final list = data['data'] as List<dynamic>;
      return list
          .map((j) => KaliteOnayResponseDto.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
