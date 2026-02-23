import '../../../../core/models/paged_result.dart';
import '../../domain/entities/final_kontrol_form.dart';
import '../../domain/repositories/i_final_kontrol_repository.dart';
import '../datasources/final_kontrol_remote_datasource.dart';
import '../models/final_kontrol_form_dto.dart';

class FinalKontrolRepositoryImpl implements IFinalKontrolRepository {
  final FinalKontrolRemoteDataSource _remoteDataSource;

  FinalKontrolRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<FinalKontrolForm>> getAll() async {
    await _remoteDataSource.getAll();
    // Return empty list since we migrated to new entity structure
    return [];
  }

  @override
  Future<PagedResult<FinalKontrolRecord>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
    int? vardiyaId,
  }) async {
    final pagedDtos = await _remoteDataSource.getForms(
      pageNumber: pageNumber,
      pageSize: pageSize,
      startDate: startDate,
      endDate: endDate,
      vardiyaId: vardiyaId,
    );

    return PagedResult<FinalKontrolRecord>(
      items: pagedDtos.items.map((dto) => FinalKontrolRecord(
        id: dto.id,
        islemTarihi: dto.islemTarihi,
        vardiyaId: dto.vardiyaId,
        vardiyaAdi: dto.vardiyaAdi,
        musteriAdi: dto.musteriAdi,
        urunId: dto.urunId,
        paletIzlenebilirlikNo: dto.paletIzlenebilirlikNo,
        paletNo: dto.paletNo,
        islemTipi: dto.islemTipi,
        adet: dto.adet,
        paketAdet: dto.paketAdet,
        reworkAdet: dto.reworkAdet,
        retKoduId: dto.retKoduId,
        retKodu: dto.retKodu,
        retAdet: dto.retAdet,
        aciklama: dto.aciklama,
        kullaniciId: dto.kullaniciId,
        kullaniciAdi: dto.kullaniciAdi,
      )).toList(),
      totalCount: pagedDtos.totalCount,
      pageNumber: pagedDtos.pageNumber,
      pageSize: pagedDtos.pageSize,
      totalPages: pagedDtos.totalPages,
      hasNextPage: pagedDtos.hasNextPage,
      hasPreviousPage: pagedDtos.hasPreviousPage,
    );
  }

  @override
  Future<FinalKontrolBulkResponseDto> createForm(FinalKontrolRequestDto requestDto) async {
    return _remoteDataSource.createForm(requestDto);
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
