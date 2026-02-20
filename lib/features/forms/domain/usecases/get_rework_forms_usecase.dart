import '../entities/rework_form.dart';
import '../repositories/i_rework_repository.dart';

class GetReworkFormsUseCase {
  final IReworkRepository _repository;

  GetReworkFormsUseCase(this._repository);

  Future<List<ReworkForm>> call() {
    return _repository.getAll();
  }
}
