import 'package:dio/dio.dart';
import '../models/rework_form_dto.dart';

class ReworkRemoteDataSource {
  final Dio _dio;

  ReworkRemoteDataSource(this._dio);

  Future<List<ReworkFormDto>> getAll() async {
    final response = await _dio.get('/rework');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => ReworkFormDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ReworkFormDto> getById(int id) async {
    final response = await _dio.get('/rework/$id');
    return ReworkFormDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<int> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/rework', data: data);
    return response.data['id'] as int;
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _dio.put('/rework/$id', data: data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/rework/$id');
  }
}
