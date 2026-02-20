import '../entities/giris_kalite_kontrol_form.dart';
import '../repositories/i_giris_kalite_kontrol_repository.dart';

class GetGirisKaliteKontrolFormsUseCase {
  final IGirisKaliteKontrolRepository _repository;

  GetGirisKaliteKontrolFormsUseCase(this._repository);

  Future<List<GirisKaliteKontrolForm>> call() {
    return _repository.getAll();
  }
}
