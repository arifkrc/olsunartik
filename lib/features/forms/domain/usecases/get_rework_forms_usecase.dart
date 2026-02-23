import '../../../../core/models/paged_result.dart';
import '../entities/rework_form.dart';
import '../repositories/i_rework_repository.dart';

class GetReworkFormsUseCase {
  final IReworkRepository _repository;

  GetReworkFormsUseCase(this._repository);

  Future<PagedResult<ReworkForm>> call({int pageNumber = 1, int pageSize = 10}) {
    return _repository.getForms(pageNumber: pageNumber, pageSize: pageSize);
  }
}
