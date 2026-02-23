import 'package:dio/dio.dart';
import '../models/fire_analiz_dto.dart';

class FireAnalizRemoteDataSource {
  final Dio _dioClient;

  FireAnalizRemoteDataSource(this._dioClient);

  /// Excel veya form verisi sonrası analizi hesaplamak için kullanılır
  Future<FireAnalizDetayDto> hesapla(String analizTarihi) async {
    try {
      final response = await _dioClient.post(
        'fire-analiz/hesapla',
        data: {
          'analizTarihi': analizTarihi,
        },
      );
      
      return FireAnalizDetayDto.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Fire analiz hesaplama hatası: $e');
    }
  }

  /// Gününe ait detaylı analizi çekmek için kullanılır
  Future<FireAnalizDetayDto> getDetayByTarih(String analizTarihi) async {
    try {
      final response = await _dioClient.get(
        'fire-analiz/$analizTarihi',
      );
      
      return FireAnalizDetayDto.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Fire analiz detayı getirme hatası: $e');
    }
  }

  /// Sayfalanmış analizleri liste şeklinde çeker
  Future<List<FireAnalizDetayDto>> getList({
    int pageNumber = 1,
    int pageSize = 20,
    String? baslangicTarihi,
    String? bitisTarihi,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      if (baslangicTarihi != null && baslangicTarihi.isNotEmpty) {
        queryParams['baslangicTarihi'] = baslangicTarihi;
      }
      if (bitisTarihi != null && bitisTarihi.isNotEmpty) {
        queryParams['bitisTarihi'] = bitisTarihi;
      }

      final response = await _dioClient.get(
        'fire-analiz',
        queryParameters: queryParams,
      );
      
      final List<dynamic> items = response.data['data']['items'] ?? [];
      return items.map((e) => FireAnalizDetayDto.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Fire analiz listesi getirme hatası: $e');
    }
  }
}
