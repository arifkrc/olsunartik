import 'package:dio/dio.dart';
import '../models/uretim_bilgisi_bulk_dto.dart';

class UretimBilgisiRemoteDataSource {
  final Dio _dioClient;

  UretimBilgisiRemoteDataSource(this._dioClient);

  Future<void> bulkInsert(UretimBilgisiBulkRequestDto request) async {
    try {
      final response = await _dioClient.post(
        'uretim-bilgisi/bulk',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Toplu üretim kaydı başarısız oldu: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Toplu üretim kaydı hatası: ${e.message}');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }
}
