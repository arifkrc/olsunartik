import '../entities/audit_action.dart';

abstract class IAuditRepository {
  Future<List<AuditAction>> getMyActions({
    required int pageNumber,
    required int pageSize,
  });
}
