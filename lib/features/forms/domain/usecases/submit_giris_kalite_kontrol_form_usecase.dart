import '../entities/giris_kalite_kontrol_form.dart';
import '../repositories/i_giris_kalite_kontrol_repository.dart';

class SubmitGirisKaliteKontrolFormUseCase {
  final IGirisKaliteKontrolRepository _repository;

  SubmitGirisKaliteKontrolFormUseCase(this._repository);

  Future<int> call(GirisKaliteKontrolForm form) {
    return _repository.create(form);
  }
}
