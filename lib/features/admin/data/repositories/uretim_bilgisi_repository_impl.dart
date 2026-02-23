import '../../domain/repositories/i_uretim_bilgisi_repository.dart';
import '../datasources/uretim_bilgisi_remote_datasource.dart';
import '../models/uretim_bilgisi_bulk_dto.dart';

class UretimBilgisiRepositoryImpl implements IUretimBilgisiRepository {
  final UretimBilgisiRemoteDataSource _remoteDataSource;

  UretimBilgisiRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> bulkInsert(UretimBilgisiBulkRequestDto request) async {
    return await _remoteDataSource.bulkInsert(request);
  }
}
