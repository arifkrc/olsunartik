import '../entities/numune_form.dart';
import '../repositories/i_numune_repository.dart';

class SubmitNumuneFormUseCase {
  final INumuneRepository _repository;

  SubmitNumuneFormUseCase(this._repository);

  Future<int> call(NumuneForm form) {
    return _repository.create(form);
  }
}
