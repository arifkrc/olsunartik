import 'package:dio/dio.dart';
import '../../domain/entities/ret_kod.dart';

/// Ret Kodu Remote DataSource
/// GET /api/lookup/ret-kodlari
class RetKodRemoteDataSource {
  final Dio _dio;

  RetKodRemoteDataSource(this._dio);

  Future<List<RetKod>> getAll() async {
    try {
      final response = await _dio.get('/api/lookup/ret-kodlari');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final list = data['data'] as List<dynamic>;
          return list.map((json) {
            final j = json as Map<String, dynamic>;
            return RetKod(
              id: j['id'] as int,
              kod: j['kod'] as String,
              aciklama: j['aciklama'] as String,
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
