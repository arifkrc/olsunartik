import '../../../../core/models/paged_result.dart';
import '../entities/final_kontrol_form.dart';
import '../repositories/i_final_kontrol_repository.dart';

class GetFinalKontrolFormsUseCase {
  final IFinalKontrolRepository _repository;

  GetFinalKontrolFormsUseCase(this._repository);

  Future<PagedResult<FinalKontrolRecord>> call({int pageNumber = 1, int pageSize = 10}) {
    return _repository.getForms(pageNumber: pageNumber, pageSize: pageSize);
  }
}
