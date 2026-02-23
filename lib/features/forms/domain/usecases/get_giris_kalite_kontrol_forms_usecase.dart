import '../../../../core/models/paged_result.dart';
import '../entities/giris_kalite_kontrol_form.dart';
import '../repositories/i_giris_kalite_kontrol_repository.dart';

class GetGirisKaliteKontrolFormsUseCase {
  final IGirisKaliteKontrolRepository _repository;

  GetGirisKaliteKontrolFormsUseCase(this._repository);

  Future<PagedResult<GirisKaliteKontrolForm>> call({int pageNumber = 1, int pageSize = 10}) {
    return _repository.getForms(pageNumber: pageNumber, pageSize: pageSize);
  }
}
