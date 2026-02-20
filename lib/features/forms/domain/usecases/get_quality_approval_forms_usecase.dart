import '../entities/quality_approval_form.dart';
import '../repositories/i_quality_approval_repository.dart';

class GetQualityApprovalFormsUseCase {
  final IQualityApprovalRepository _repository;

  GetQualityApprovalFormsUseCase(this._repository);

  Future<List<QualityApprovalForm>> call() {
    return _repository.getAll();
  }
}
