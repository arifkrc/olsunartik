import '../../domain/entities/palet_giris_form.dart';
import '../../domain/repositories/i_palet_giris_repository.dart';
import '../datasources/palet_giris_remote_datasource.dart';
import '../models/palet_giris_form_dto.dart';

class PaletGirisRepositoryImpl implements IPaletGirisRepository {
  final PaletGirisRemoteDataSource _remoteDataSource;

  PaletGirisRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PaletGirisForm>> getAll() async {
    final dtos = await _remoteDataSource.getAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<PaletGirisForm> getById(int id) async {
    final dto = await _remoteDataSource.getById(id);
    return dto.toEntity();
  }

  @override
  Future<int> create(PaletGirisForm form) async {
    final dto = PaletGirisFormDto(
      id: form.id,
      paletNo: form.paletNo,
      tedarikci: form.tedarikci,
      urunKodu: form.urunKodu,
      miktar: form.miktar,
      durum: form.durum,
      hasar: form.hasar,
      kayitTarihi: form.kayitTarihi,
    );
    return await _remoteDataSource.create(dto.toJson());
  }

  @override
  Future<void> update(PaletGirisForm form) async {
    final dto = PaletGirisFormDto(
      id: form.id,
      paletNo: form.paletNo,
      tedarikci: form.tedarikci,
      urunKodu: form.urunKodu,
      miktar: form.miktar,
      durum: form.durum,
      hasar: form.hasar,
      kayitTarihi: form.kayitTarihi,
    );
    await _remoteDataSource.update(form.id!, dto.toJson());
  }

  @override
  Future<void> delete(int id) async {
    await _remoteDataSource.delete(id);
  }
}
