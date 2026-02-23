import '../../../../core/models/paged_result.dart';
import 'package:dio/dio.dart';
import '../models/final_kontrol_form_dto.dart';

class FinalKontrolRemoteDataSource {
  final Dio _dio;

  FinalKontrolRemoteDataSource(this._dio);

  Future<PagedResult<FinalKontrolResponseItemDto>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
    int? vardiyaId,
  }) async {
    final response = await _dio.get(
      'final-kontrol',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (startDate != null) 'startDate': startDate.toUtc().toIso8601String(),
        if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
        if (vardiyaId != null) 'vardiyaId': vardiyaId,
      },
    );
    if (response.data['success'] == true) {
      return PagedResult<FinalKontrolResponseItemDto>.fromJson(
        response.data['data'],
        (j) => FinalKontrolResponseItemDto.fromJson(j),
      );
    }
    throw Exception(response.data['message'] ?? 'Veriler alınamadı');
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _dio.get('FinalKontrol');
    return (response.data['data'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final response = await _dio.get('FinalKontrol/$id');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<FinalKontrolBulkResponseDto> createForm(FinalKontrolRequestDto data) async {
    final response = await _dio.post('FinalKontrol/bulk', data: data.toJson());
    
    if (response.data != null) {
      return FinalKontrolBulkResponseDto.fromJson(response.data);
    } else {
      throw Exception('Form kaydedilemedi: Bos donus.');
    }
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('finalkontrol/$id', data: data);
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
    await _dio.delete('/final-kontrol/$id');
  }
}
