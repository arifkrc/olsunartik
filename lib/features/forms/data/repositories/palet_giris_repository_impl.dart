import '../../../../core/models/paged_result.dart';
import '../../domain/entities/palet_giris_form.dart';
import '../../domain/repositories/i_palet_giris_repository.dart';
import '../datasources/palet_giris_remote_datasource.dart';
import '../models/palet_giris_form_dto.dart';

class PaletGirisRepositoryImpl implements IPaletGirisRepository {
  final PaletGirisRemoteDataSource _remoteDataSource;

  PaletGirisRepositoryImpl(this._remoteDataSource);

  @override
  Future<PagedResult<PaletGirisForm>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pagedDtos = await _remoteDataSource.getPaginated(
      pageNumber: pageNumber,
      pageSize: pageSize,
      startDate: startDate,
      endDate: endDate,
    );
    return PagedResult<PaletGirisForm>(
      items: pagedDtos.items.map((dto) => dto.toEntity()).toList(),
      totalCount: pagedDtos.totalCount,
      pageNumber: pagedDtos.pageNumber,
      pageSize: pagedDtos.pageSize,
      totalPages: pagedDtos.totalPages,
      hasNextPage: pagedDtos.hasNextPage,
      hasPreviousPage: pagedDtos.hasPreviousPage,
    );
  }

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
      tedarikciAdi: form.tedarikciAdi,
      irsaliyeNo: form.irsaliyeNo,
      urunAdi: form.urunAdi,
      nemOlcumleri: form.nemOlcumleri,
      fizikiYapiKontrol: form.fizikiYapiKontrol,
      muhurKontrol: form.muhurKontrol,
      irsaliyeEslestirme: form.irsaliyeEslestirme,
      aciklama: form.aciklama,
      fotografYolu: form.fotografYolu,
      kayitTarihi: form.kayitTarihi,
    );
    return await _remoteDataSource.create(dto.toJson());
  }

  @override
  Future<void> update(int id, Map<String, dynamic> data) async {
    await _remoteDataSource.update(id, data);
  }

  @override
  Future<void> delete(int id) async {
    await _remoteDataSource.delete(id);
  }
}
