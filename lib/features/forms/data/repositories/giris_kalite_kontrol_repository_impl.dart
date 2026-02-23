import '../../../../core/models/paged_result.dart';
import '../../domain/entities/giris_kalite_kontrol_form.dart';
import '../../domain/repositories/i_giris_kalite_kontrol_repository.dart';
import '../datasources/giris_kalite_kontrol_remote_datasource.dart';
import '../models/giris_kalite_kontrol_form_dto.dart';

class GirisKaliteKontrolRepositoryImpl
    implements IGirisKaliteKontrolRepository {
  final GirisKaliteKontrolRemoteDataSource _remoteDataSource;

  GirisKaliteKontrolRepositoryImpl(this._remoteDataSource);

  @override
  Future<PagedResult<GirisKaliteKontrolForm>> getForms({
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
    return PagedResult<GirisKaliteKontrolForm>(
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
  Future<List<GirisKaliteKontrolForm>> getAll() async {
    final dtos = await _remoteDataSource.getAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<GirisKaliteKontrolForm> getById(int id) async {
    final dto = await _remoteDataSource.getById(id);
    return dto.toEntity();
  }

  @override
  Future<int> create(GirisKaliteKontrolForm form) async {
    final dto = GirisKaliteKontrolFormDto(
      id: form.id,
      tedarikci: form.tedarikci,
      urunKodu: form.urunKodu,
      lotNo: form.lotNo,
      miktar: form.miktar,
      kabul: form.kabul,
      retNedeni: form.retNedeni,
      aciklama: form.aciklama,
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
