import '../entities/numune_form.dart';
import '../repositories/i_numune_repository.dart';

class GetNumuneFormsUseCase {
  final INumuneRepository _repository;

  GetNumuneFormsUseCase(this._repository);

  Future<List<NumuneForm>> call() {
    return _repository.getAll();
  }
}
