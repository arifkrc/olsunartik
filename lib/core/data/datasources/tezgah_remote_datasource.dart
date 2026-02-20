import 'package:dio/dio.dart';
import '../../domain/entities/tezgah.dart';

class TezgahRemoteDataSource {
  final Dio _dio;

  TezgahRemoteDataSource(this._dio);

  Future<List<Tezgah>> getAll() async {
    try {
      final response = await _dio.get('/api/lookup/tezgahlar');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final list = data['data'] as List<dynamic>;
          return list.map((json) {
            final j = json as Map<String, dynamic>;
            return Tezgah(
              id: j['id'] as int,
              tezgahNo: j['tezgahNo'] as String,
              tezgahTuru: j['tezgahTuru'] as String,
            );
          }).toList();
        }
      }
      return [];
    } on DioException {
      rethrow;
    }
  }
}
