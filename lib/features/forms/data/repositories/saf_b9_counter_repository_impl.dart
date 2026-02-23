import '../../../../core/models/paged_result.dart';
import '../../domain/repositories/i_saf_b9_counter_repository.dart';
import '../datasources/saf_b9_counter_remote_datasource.dart';
import '../models/saf_b9_counter_entry_dto.dart';

class SafB9CounterRepositoryImpl implements ISafB9CounterRepository {
  final SafB9CounterRemoteDataSource _remoteDataSource;

  SafB9CounterRepositoryImpl(this._remoteDataSource);

  @override
  Future<PagedResult<SAFBResponseDto>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
    int? vardiyaId,
  }) async {
    return await _remoteDataSource.getForms(
      pageNumber: pageNumber,
      pageSize: pageSize,
      startDate: startDate,
      endDate: endDate,
      vardiyaId: vardiyaId,
    );
  }

  @override
  Future<String> create(SAFBRequestDto request) async {
    return await _remoteDataSource.create(request);
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
