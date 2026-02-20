import '../entities/palet_giris_form.dart';
import '../repositories/i_palet_giris_repository.dart';

class SubmitPaletGirisFormUseCase {
  final IPaletGirisRepository _repository;

  SubmitPaletGirisFormUseCase(this._repository);

  Future<int> call(PaletGirisForm form) {
    return _repository.create(form);
  }
}
