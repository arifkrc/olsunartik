import 'package:dio/dio.dart';
import '../models/measurement_instrument_dto.dart';

class MeasurementInstrumentRemoteDataSource {
  final Dio _dio;

  MeasurementInstrumentRemoteDataSource(this._dio);

  Future<List<MeasurementInstrumentDto>> getAll() async {
    final response = await _dio.get('/olcu-aleti');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map(
          (json) =>
              MeasurementInstrumentDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<MeasurementInstrumentDto> getById(int id) async {
    final response = await _dio.get('/olcu-aleti/$id');
    return MeasurementInstrumentDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<int> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/olcu-aleti', data: data);
    return response.data['id'] as int;
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _dio.put('/olcu-aleti/$id', data: data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/olcu-aleti/$id');
  }
}
