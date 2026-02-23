import '../../../../core/models/paged_result.dart';
import 'package:dio/dio.dart';
import '../models/palet_giris_form_dto.dart';

class PaletGirisRemoteDataSource {
  final Dio _dio;

  PaletGirisRemoteDataSource(this._dio);

  Future<PagedResult<PaletGirisFormDto>> getPaginated({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _dio.get(
      'paletgiris/paginated',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (startDate != null) 'startDate': startDate.toUtc().toIso8601String(),
        if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
      },
    );
    if (response.data['success'] == true) {
      return PagedResult<PaletGirisFormDto>.fromJson(
        response.data['data'],
        (j) => PaletGirisFormDto.fromJson(j),
      );
    }
    throw Exception(response.data['message'] ?? 'Veriler alınamadı');
  }

  Future<List<PaletGirisFormDto>> getAll() async {
    final response = await _dio.get('palet-giris');
    return (response.data['data'] as List)
        .map((j) => PaletGirisFormDto.fromJson(j))
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
