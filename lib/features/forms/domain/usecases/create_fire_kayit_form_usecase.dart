import '../repositories/i_fire_kayit_repository.dart';
import '../../data/models/fire_kayit_formu_dto.dart';

class CreateFireKayitFormUseCase {
  final IFireKayitRepository _repository;

  CreateFireKayitFormUseCase(this._repository);

  Future<int> call(FireKayitRequestDto data) {
    return _repository.createForm(data);
  }
}
