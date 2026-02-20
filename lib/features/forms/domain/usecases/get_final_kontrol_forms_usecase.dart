import '../entities/final_kontrol_form.dart';
import '../repositories/i_final_kontrol_repository.dart';

class GetFinalKontrolFormsUseCase {
  final IFinalKontrolRepository _repository;

  GetFinalKontrolFormsUseCase(this._repository);

  Future<List<FinalKontrolForm>> call() {
    return _repository.getAll();
  }
}
