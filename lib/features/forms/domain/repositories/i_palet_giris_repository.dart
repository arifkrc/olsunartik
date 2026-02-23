import '../../../../core/models/paged_result.dart';
import '../entities/palet_giris_form.dart';

abstract class IPaletGirisRepository {
  Future<PagedResult<PaletGirisForm>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<PaletGirisForm>> getAll();
  Future<PaletGirisForm> getById(int id);
  Future<int> create(PaletGirisForm form);
  Future<void> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}
