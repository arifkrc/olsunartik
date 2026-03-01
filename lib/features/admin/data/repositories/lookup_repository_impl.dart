import '../../domain/repositories/i_lookup_repository.dart';
import '../datasources/lookup_remote_datasource.dart';

class LookupRepositoryImpl implements ILookupRepository {
  final LookupRemoteDataSource _remoteDataSource;

  LookupRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Map<String, dynamic>>> getAll(String endpoint, {bool? isActive}) {
    return _remoteDataSource.getAll(endpoint, isActive: isActive);
  }

  @override
  Future<Map<String, dynamic>> create(String endpoint, Map<String, dynamic> data) {
    return _remoteDataSource.create(endpoint, data);
  }

  @override
  Future<Map<String, dynamic>> update(String endpoint, int id, Map<String, dynamic> data) {
    return _remoteDataSource.update(endpoint, id, data);
  }

  @override
  Future<void> delete(String endpoint, int id, Map<String, dynamic> data) {
    return _remoteDataSource.delete(endpoint, id, data);
  }
}
