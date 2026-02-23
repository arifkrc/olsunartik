import '../../../../core/models/paged_result.dart';
import '../../data/models/saf_b9_counter_entry_dto.dart';

abstract class ISafB9CounterRepository {
  Future<PagedResult<SAFBResponseDto>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
    int? vardiyaId,
  });
  Future<String> create(SAFBRequestDto request);
  Future<void> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}
