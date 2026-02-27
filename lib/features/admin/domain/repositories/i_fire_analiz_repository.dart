import '../../data/models/fire_analiz_dto.dart';

abstract class IFireAnalizRepository {
  Future<FireAnalizDetayDto> hesapla(String analizTarihi, {int? frenbuUretimAdeti});
  Future<FireAnalizDetayDto> getDetayByTarih(String analizTarihi);
  Future<List<FireAnalizDetayDto>> getList({
    int pageNumber = 1,
    int pageSize = 20,
    String? baslangicTarihi,
    String? bitisTarihi,
  });
}
