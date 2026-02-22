import 'package:dio/dio.dart';
import '../models/palet_giris_form_dto.dart';

class PaletGirisRemoteDataSource {
  final Dio _dio;

  PaletGirisRemoteDataSource(this._dio);

  Future<List<PaletGirisFormDto>> getAll() async {
    final response = await _dio.get('palet-giris');
    final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((json) => PaletGirisFormDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PaletGirisFormDto> getById(int id) async {
    final response = await _dio.get('palet-giris/$id');
    return PaletGirisFormDto.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<int> create(Map<String, dynamic> data) async {
    final response = await _dio.post('palet-giris', data: data);
    return response.data['data']['id'] as int;
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('palet-giris/$id', data: data);
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
    await _dio.delete('palet-giris/$id');
  }
}
