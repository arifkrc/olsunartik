import '../../../../core/models/paged_result.dart';
import '../entities/quality_approval_form.dart';

abstract class IQualityApprovalRepository {
  Future<PagedResult<QualityApprovalForm>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
    int? vardiyaId,
  });
  Future<List<QualityApprovalForm>> getAll();
  Future<QualityApprovalForm> getById(int id);
  Future<String> create(QualityApprovalForm form);
  Future<void> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}

