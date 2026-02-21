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
    await _dio.put('palet-giris/$id', data: data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('palet-giris/$id');
  }
}
