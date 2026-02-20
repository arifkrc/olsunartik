import '../entities/rework_form.dart';
import '../repositories/i_rework_repository.dart';

class SubmitReworkFormUseCase {
  final IReworkRepository _repository;

  SubmitReworkFormUseCase(this._repository);

  Future<int> call(ReworkForm form) {
    return _repository.create(form);
  }
}
