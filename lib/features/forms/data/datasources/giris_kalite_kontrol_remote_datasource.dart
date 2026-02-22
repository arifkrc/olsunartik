import 'package:dio/dio.dart';
import '../models/giris_kalite_kontrol_form_dto.dart';

class GirisKaliteKontrolRemoteDataSource {
  final Dio _dio;

  GirisKaliteKontrolRemoteDataSource(this._dio);

  Future<List<GirisKaliteKontrolFormDto>> getAll() async {
    final response = await _dio.get('giris-kalite-kontrol');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map(
          (json) =>
              GirisKaliteKontrolFormDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<GirisKaliteKontrolFormDto> getById(int id) async {
    final response = await _dio.get('giris-kalite-kontrol/$id');
    return GirisKaliteKontrolFormDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<int> create(Map<String, dynamic> data) async {
    final response = await _dio.post('giris-kalite-kontrol', data: data);
    return response.data['id'] as int;
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('giriskalite/$id', data: data);
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
    await _dio.delete('giris-kalite-kontrol/$id');
  }
}
