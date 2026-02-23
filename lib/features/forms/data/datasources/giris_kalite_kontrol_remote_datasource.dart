import '../../../../core/models/paged_result.dart';
import 'package:dio/dio.dart';
import '../models/giris_kalite_kontrol_form_dto.dart';

class GirisKaliteKontrolRemoteDataSource {
  final Dio _dio;

  GirisKaliteKontrolRemoteDataSource(this._dio);

  Future<PagedResult<GirisKaliteKontrolFormDto>> getPaginated({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _dio.get(
      'giriskalite',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (startDate != null) 'startDate': startDate.toUtc().toIso8601String(),
        if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
      },
    );
    if (response.data != null) {
      // Assuming success structure or direct PagedResult structure
      // Let's check if it's wrapped in 'data'
      final json = response.data;
      final data = (json is Map && json.containsKey('data')) ? json['data'] : json;
      
      return PagedResult<GirisKaliteKontrolFormDto>.fromJson(
        data as Map<String, dynamic>,
        (j) => GirisKaliteKontrolFormDto.fromJson(j),
      );
    }
    throw Exception('Veriler alınamadı');
  }

  Future<List<GirisKaliteKontrolFormDto>> getAll() async {
    final response = await _dio.get('giris-kalite-kontrol');
    return (response.data as List)
        .map((j) => GirisKaliteKontrolFormDto.fromJson(j))
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
