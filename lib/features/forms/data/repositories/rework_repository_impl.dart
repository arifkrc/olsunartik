import '../../../../core/models/paged_result.dart';
import '../../domain/entities/rework_form.dart';
import '../../domain/repositories/i_rework_repository.dart';
import '../datasources/rework_remote_datasource.dart';
import '../models/rework_form_dto.dart';

class ReworkRepositoryImpl implements IReworkRepository {
  final ReworkRemoteDataSource _remoteDataSource;

  ReworkRepositoryImpl(this._remoteDataSource);

  @override
  Future<PagedResult<ReworkForm>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
    int? vardiyaId,
  }) async {
    final pagedDtos = await _remoteDataSource.getPaginated(
      pageNumber: pageNumber,
      pageSize: pageSize,
      startDate: startDate,
      endDate: endDate,
      vardiyaId: vardiyaId,
    );
    return PagedResult<ReworkForm>(
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
  Future<void> createBulk(List<ReworkForm> forms) async {
    final payloadList = forms.map((form) {
      final dto = ReworkFormDto(
        urunId: form.urunId,
        adet: form.adet,
        retKoduId: form.retKoduId,
        sarjNo: form.sarjNo,
        sonuc: form.sonuc,
      );
      return dto.toJson();
    }).toList();

    await _remoteDataSource.createBulk(payloadList);
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
