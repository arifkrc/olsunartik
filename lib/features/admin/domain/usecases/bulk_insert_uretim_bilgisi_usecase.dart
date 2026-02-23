import '../repositories/i_uretim_bilgisi_repository.dart';
import '../../data/models/uretim_bilgisi_bulk_dto.dart';

class BulkInsertUretimBilgisiUseCase {
  final IUretimBilgisiRepository _repository;

  BulkInsertUretimBilgisiUseCase(this._repository);

  Future<void> call(UretimBilgisiBulkRequestDto request) async {
    return await _repository.bulkInsert(request);
  }
}
