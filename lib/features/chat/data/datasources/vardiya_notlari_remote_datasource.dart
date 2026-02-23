import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/paged_result.dart';
import '../models/vardiya_notlari_dto.dart';

class VardiyaNotlariRemoteDataSource {
  final Dio _dio;

  VardiyaNotlariRemoteDataSource(this._dio);

  Future<PagedResult<VardiyaNotuDto>> getVardiyaNotlari({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.apiBase}/vardiya-notlari',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      final data = response.data;
      // Depending on the wrapper, we extract the paged data either directly or from a 'data' object.
      // Note: User prompt implies the plain pagination object is returned without wrapper, but sometimes there's a wrapper.
      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('success') && data['success'] == true) {
           return PagedResult<VardiyaNotuDto>.fromJson(
            data['data'],
            (j) => VardiyaNotuDto.fromJson(j),
          );
        } else if (data.containsKey('items')) {
            return PagedResult<VardiyaNotuDto>.fromJson(
              data,
              (j) => VardiyaNotuDto.fromJson(j),
            );
        }
      }
      throw Exception('Vardiya notları alınamadı. (Bilinmeyen format)');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data?['message'] ?? 'Geçersiz İstek');
      }
      throw Exception(e.message ?? 'Bilinmeyen hata');
    }
  }

  Future<VardiyaNotuDto> createVardiyaNotu(VardiyaNotuRequestDto request) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.apiBase}/vardiya-notlari',
        data: request.toJson(),
      );

      final data = response.data;
      if (data != null && data['success'] == true) {
        return VardiyaNotuDto.fromJson(data['data']);
      } else {
        throw Exception(data?['message'] ?? 'Kayıt oluşturulamadı');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        final message = errorData?['message'] ??
            (errorData?['errors'] as List?)?.first ??
            'Geçersiz İstek (400)';
        throw Exception(message);
      }
      throw Exception(e.message ?? 'Bilinmeyen hata');
    }
  }
}
