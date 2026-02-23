import '../../../../core/models/paged_result.dart';
import '../../domain/entities/quality_approval_form.dart';
import '../../domain/repositories/i_quality_approval_repository.dart';
import '../datasources/quality_approval_remote_datasource.dart';
import '../models/quality_approval_form_dto.dart';

class QualityApprovalRepositoryImpl implements IQualityApprovalRepository {
  final QualityApprovalRemoteDataSource _remoteDataSource;

  QualityApprovalRepositoryImpl(this._remoteDataSource);

  @override
  Future<PagedResult<QualityApprovalForm>> getForms({
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

    return PagedResult<QualityApprovalForm>(
      items: pagedDtos.items.map((dto) => QualityApprovalForm(
        id: dto.id,
        urunId: dto.urunId,
        urunKodu: dto.urunKodu ?? '',
        urunAdi: dto.urunAdi ?? '',
        urunTuru: dto.urunTuru ?? '',
        adet: dto.adet,
        isUygun: dto.isUygun,
        retKoduId: dto.retKoduId,
        aciklama: dto.aciklama,
        islemTarihi: dto.islemTarihi,
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
  Future<String> create(QualityApprovalForm form) async {
    final request = KaliteOnayRequestDto.fromEntity(form);
    return await _remoteDataSource.create(request);
  }

  @override
  Future<List<QualityApprovalForm>> getAll() async {
    final dtos = await _remoteDataSource.getAll();
    return dtos.map((dto) => QualityApprovalForm(
      id: dto.id,
      urunId: dto.urunId,
      urunKodu: dto.urunKodu ?? '',
      urunAdi: dto.urunAdi ?? '',
      urunTuru: dto.urunTuru ?? '',
      adet: dto.adet,
      isUygun: dto.isUygun,
      retKoduId: dto.retKoduId,
      aciklama: dto.aciklama,
      islemTarihi: dto.islemTarihi,
    )).toList();
  }

  @override
  Future<QualityApprovalForm> getById(int id) async {
    throw UnimplementedError('Henüz implement edilmedi');
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
