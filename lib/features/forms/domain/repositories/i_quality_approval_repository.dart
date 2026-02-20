import '../entities/quality_approval_form.dart';

abstract class IQualityApprovalRepository {
  Future<List<QualityApprovalForm>> getAll();
  Future<QualityApprovalForm> getById(int id);
  Future<String> create(QualityApprovalForm form);
  Future<void> update(QualityApprovalForm form);
  Future<void> delete(int id);
}

