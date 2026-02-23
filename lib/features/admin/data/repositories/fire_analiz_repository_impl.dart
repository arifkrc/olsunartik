import '../../domain/repositories/i_fire_analiz_repository.dart';
import '../datasources/fire_analiz_remote_datasource.dart';
import '../models/fire_analiz_dto.dart';

class FireAnalizRepositoryImpl implements IFireAnalizRepository {
  final FireAnalizRemoteDataSource _remoteDataSource;

  FireAnalizRepositoryImpl(this._remoteDataSource);

  @override
  Future<FireAnalizDetayDto> hesapla(String analizTarihi) async {
    return await _remoteDataSource.hesapla(analizTarihi);
  }

  @override
  Future<FireAnalizDetayDto> getDetayByTarih(String analizTarihi) async {
    return await _remoteDataSource.getDetayByTarih(analizTarihi);
  }

  @override
  Future<List<FireAnalizDetayDto>> getList({
    int pageNumber = 1,
    int pageSize = 20,
    String? baslangicTarihi,
    String? bitisTarihi,
  }) async {
    return await _remoteDataSource.getList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      baslangicTarihi: baslangicTarihi,
      bitisTarihi: bitisTarihi,
    );
  }
}
