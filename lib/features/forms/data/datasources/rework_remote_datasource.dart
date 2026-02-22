import 'package:dio/dio.dart';
import '../models/rework_form_dto.dart';

class ReworkRemoteDataSource {
  final Dio _dio;

  ReworkRemoteDataSource(this._dio);

  Future<List<ReworkFormDto>> getAll() async {
    final response = await _dio.get('Rework');
    final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((json) => ReworkFormDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ReworkFormDto> getById(int id) async {
    final response = await _dio.get('Rework/$id');
    return ReworkFormDto.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Bulk POST işlemi
  Future<void> createBulk(List<Map<String, dynamic>> reworks) async {
    await _dio.post(
      'Rework/bulk',
      data: {'reworks': reworks},
    );
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('rework/$id', data: data);
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
    await _dio.delete('Rework/$id');
  }
}
