import '../../../../core/models/paged_result.dart';
import '../entities/fire_kayit_formu.dart';
import '../repositories/i_fire_kayit_repository.dart';

class GetFireKayitFormsUseCase {
  final IFireKayitRepository _repository;

  GetFireKayitFormsUseCase(this._repository);

  Future<PagedResult<FireKayitFormu>> call({int pageNumber = 1, int pageSize = 10}) {
    return _repository.getForms(pageNumber: pageNumber, pageSize: pageSize);
  }
}
