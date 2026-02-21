import 'package:dio/dio.dart';
import '../models/numune_form_dto.dart';

class NumuneRemoteDataSource {
  final Dio _dio;

  NumuneRemoteDataSource(this._dio);

  Future<List<NumuneFormDto>> getAll() async {
    final response = await _dio.get('numune');
    final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((json) => NumuneFormDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<NumuneFormDto> getById(int id) async {
    final response = await _dio.get('numune/$id');
    return NumuneFormDto.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<int> create(Map<String, dynamic> data) async {
    final response = await _dio.post('numune', data: data);
    return response.data['data']['id'] as int;
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _dio.put('numune/$id', data: data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('numune/$id');
  }
}
