import '../../domain/entities/numune_form.dart';
import '../../domain/repositories/i_numune_repository.dart';
import '../datasources/numune_remote_datasource.dart';
import '../models/numune_form_dto.dart';

class NumuneRepositoryImpl implements INumuneRepository {
  final NumuneRemoteDataSource _remoteDataSource;

  NumuneRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<NumuneForm>> getAll() async {
    final dtos = await _remoteDataSource.getAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<NumuneForm> getById(int id) async {
    final dto = await _remoteDataSource.getById(id);
    return dto.toEntity();
  }

  @override
  Future<int> create(NumuneForm form) async {
    final dto = NumuneFormDto(
      id: form.id,
      urunKodu: form.urunKodu,
      urunAdi: form.urunAdi,
      urunTuru: form.urunTuru,
      adet: form.adet,
      testSonucu: form.testSonucu,
      aciklama: form.aciklama,
      kayitTarihi: form.kayitTarihi,
    );
    return await _remoteDataSource.create(dto.toJson());
  }

  @override
  Future<void> update(NumuneForm form) async {
    final dto = NumuneFormDto(
      id: form.id,
      urunKodu: form.urunKodu,
      urunAdi: form.urunAdi,
      urunTuru: form.urunTuru,
      adet: form.adet,
      testSonucu: form.testSonucu,
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
