import '../../../../core/models/paged_result.dart';
import '../entities/quality_approval_form.dart';
import '../repositories/i_quality_approval_repository.dart';

class GetQualityApprovalFormsUseCase {
  final IQualityApprovalRepository _repository;

  GetQualityApprovalFormsUseCase(this._repository);

  Future<PagedResult<QualityApprovalForm>> call({int pageNumber = 1, int pageSize = 10}) {
    return _repository.getForms(pageNumber: pageNumber, pageSize: pageSize);
  }
}
