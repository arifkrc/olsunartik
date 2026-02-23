import '../../../../core/models/paged_result.dart';
import '../entities/vardiya_notu.dart';

abstract class IVardiyaNotlariRepository {
  Future<PagedResult<VardiyaNotu>> getVardiyaNotlari({
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<VardiyaNotu> createVardiyaNotu(
    String baslik,
    String notMetni,
    int oncelikDerecesi,
  );
}
