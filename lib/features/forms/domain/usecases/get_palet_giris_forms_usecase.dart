import '../entities/palet_giris_form.dart';
import '../repositories/i_palet_giris_repository.dart';

class GetPaletGirisFormsUseCase {
  final IPaletGirisRepository _repository;

  GetPaletGirisFormsUseCase(this._repository);

  Future<List<PaletGirisForm>> call() {
    return _repository.getAll();
  }
}
