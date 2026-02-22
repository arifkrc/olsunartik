import '../entities/quality_approval_form.dart';

abstract class IQualityApprovalRepository {
  Future<List<QualityApprovalForm>> getAll();
  Future<QualityApprovalForm> getById(int id);
  Future<String> create(QualityApprovalForm form);
  Future<void> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}

