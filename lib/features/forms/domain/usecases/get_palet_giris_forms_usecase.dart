import '../../../../core/models/paged_result.dart';
import '../entities/palet_giris_form.dart';
import '../repositories/i_palet_giris_repository.dart';

class GetPaletGirisFormsUseCase {
  final IPaletGirisRepository _repository;

  GetPaletGirisFormsUseCase(this._repository);

  Future<PagedResult<PaletGirisForm>> call({int pageNumber = 1, int pageSize = 10}) {
    return _repository.getForms(pageNumber: pageNumber, pageSize: pageSize);
  }
}
