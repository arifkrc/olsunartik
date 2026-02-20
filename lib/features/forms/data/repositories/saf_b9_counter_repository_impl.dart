import '../../domain/repositories/i_saf_b9_counter_repository.dart';
import '../datasources/saf_b9_counter_remote_datasource.dart';
import '../models/saf_b9_counter_entry_dto.dart';

class SafB9CounterRepositoryImpl implements ISafB9CounterRepository {
  final SafB9CounterRemoteDataSource _remoteDataSource;

  SafB9CounterRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> create(SAFBRequestDto request) async {
    return await _remoteDataSource.create(request);
  }
}
