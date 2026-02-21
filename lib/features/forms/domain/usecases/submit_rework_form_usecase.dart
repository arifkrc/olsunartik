import '../entities/rework_form.dart';
import '../repositories/i_rework_repository.dart';

class SubmitReworkFormUseCase {
  final IReworkRepository _repository;

  SubmitReworkFormUseCase(this._repository);

  Future<void> call(List<ReworkForm> forms) {
    return _repository.createBulk(forms);
  }
}
