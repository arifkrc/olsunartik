import 'package:dio/dio.dart';
import '../models/final_kontrol_form_dto.dart';

class FinalKontrolRemoteDataSource {
  final Dio _dio;

  FinalKontrolRemoteDataSource(this._dio);

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _dio.get('/api/FinalKontrol');
    final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
    return data.map((json) => json as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final response = await _dio.get('/api/FinalKontrol/$id');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<FinalKontrolBulkResponseDto> createForm(FinalKontrolRequestDto data) async {
    final response = await _dio.post('/api/FinalKontrol/bulk', data: data.toJson());
    
    if (response.data != null) {
      return FinalKontrolBulkResponseDto.fromJson(response.data);
    } else {
      throw Exception('Form kaydedilemedi: Bos donus.');
    }
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _dio.put('/final-kontrol/$id', data: data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/final-kontrol/$id');
  }
}
