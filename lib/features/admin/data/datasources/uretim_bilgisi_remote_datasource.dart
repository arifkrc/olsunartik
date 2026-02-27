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

  Future<void> updateUretimBilgisi(int id, int tornaAdeti) async {
    try {
      final response = await _dioClient.put(
        'uretim-bilgisi/$id',
        data: {'tornaAdeti': tornaAdeti},
      );

      if (response.statusCode != 200) {
        throw Exception('Üretim bilgisi güncelleme başarısız oldu: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Üretim bilgisi güncelleme hatası: ${e.message}');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }
}
