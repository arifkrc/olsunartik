import '../../data/models/uretim_bilgisi_bulk_dto.dart';

abstract class IUretimBilgisiRepository {
  Future<void> bulkInsert(UretimBilgisiBulkRequestDto request);
}
