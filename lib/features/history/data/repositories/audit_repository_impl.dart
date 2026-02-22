import '../../domain/entities/audit_action.dart';
import '../../domain/repositories/i_audit_repository.dart';
import '../datasources/audit_remote_datasource.dart';

class AuditRepositoryImpl implements IAuditRepository {
  final AuditRemoteDataSource _remoteDataSource;

  AuditRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AuditAction>> getMyActions({
    required int pageNumber,
    required int pageSize,
  }) async {
    final dtos = await _remoteDataSource.getMyActions(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
