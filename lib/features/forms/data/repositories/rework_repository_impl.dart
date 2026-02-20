import '../../domain/entities/rework_form.dart';
import '../../domain/repositories/i_rework_repository.dart';
import '../datasources/rework_remote_datasource.dart';
import '../models/rework_form_dto.dart';

class ReworkRepositoryImpl implements IReworkRepository {
  final ReworkRemoteDataSource _remoteDataSource;

  ReworkRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ReworkForm>> getAll() async {
    final dtos = await _remoteDataSource.getAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<ReworkForm> getById(int id) async {
    final dto = await _remoteDataSource.getById(id);
    return dto.toEntity();
  }

  @override
  Future<int> create(ReworkForm form) async {
    final dto = ReworkFormDto(
      id: form.id,
      urunKodu: form.urunKodu,
      sarjNo: form.sarjNo,
      miktar: form.miktar,
      islemId: form.islemId,
      aciklama: form.aciklama,
      kayitTarihi: form.kayitTarihi,
    );
    return await _remoteDataSource.create(dto.toJson());
  }

  @override
  Future<void> update(ReworkForm form) async {
    final dto = ReworkFormDto(
      id: form.id,
      urunKodu: form.urunKodu,
      sarjNo: form.sarjNo,
      miktar: form.miktar,
      islemId: form.islemId,
      aciklama: form.aciklama,
      kayitTarihi: form.kayitTarihi,
    );
    await _remoteDataSource.update(form.id!, dto.toJson());
  }

  @override
  Future<void> delete(int id) async {
    await _remoteDataSource.delete(id);
  }
}
