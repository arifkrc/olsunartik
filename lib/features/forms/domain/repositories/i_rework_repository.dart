import '../../../../core/models/paged_result.dart';
import '../entities/rework_form.dart';

abstract class IReworkRepository {
  Future<PagedResult<ReworkForm>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
    int? vardiyaId,
  });
  Future<List<ReworkForm>> getAll();
  Future<ReworkForm> getById(int id);
  Future<void> createBulk(List<ReworkForm> forms);
  Future<void> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}
