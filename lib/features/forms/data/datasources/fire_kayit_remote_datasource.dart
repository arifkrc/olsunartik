import 'dart:io';
import 'package:dio/dio.dart';
import '../models/fire_kayit_formu_dto.dart';

class FireKayitRemoteDataSource {
  final Dio _dio;

  FireKayitRemoteDataSource(this._dio);

  Future<List<FireKayitResponseDto>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/firekayitformu',
        queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
      );

      if (response.data['success'] == true) {
        final List<dynamic> items = response.data['data']['items'] ?? [];
        return items.map((e) => FireKayitResponseDto.fromJson(e)).toList();
      } else {
        // Fallback if structure is different or success is false
        throw Exception(response.data['message'] ?? 'Failed to fetch forms');
      }
    } catch (e) {
      // In a real app, you might want to return a local cache or throw a specific Failure
      rethrow;
    }
  }

  Future<FireKayitResponseDto> getForm(int id) async {
    final response = await _dio.get('/api/firekayitformu/$id');
    if (response.data['success'] == true) {
      return FireKayitResponseDto.fromJson(
        response.data['data'],
      ); // Assuming API returns single object in 'data'
    } else {
      throw Exception(response.data['message']);
    }
  }

  Future<int> createForm(FireKayitRequestDto data) async {
    final response = await _dio.post('/api/firekayitformu', data: data.toJson());
    if (response.data['success'] == true) {
      return response.data['data']['id'];
    } else {
      throw Exception(response.data['message']);
    }
  }

  Future<void> updateForm(int id, FireKayitRequestDto data) async {
    await _dio.put('/api/firekayitformu/$id', data: data.toJson());
  }

  Future<void> deleteForm(int id) async {
    await _dio.delete('/api/firekayitformu/$id');
  }

  Future<String> uploadPhoto(int id, File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "photo": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _dio.post(
      '/api/firekayitformu/$id/photo',
      data: formData,
    );

    if (response.data['success'] == true) {
      return response.data['data']; // Returns relative path
    } else {
      throw Exception(response.data['message']);
    }
  }
}
