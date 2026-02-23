import '../../../../core/models/paged_result.dart';
import '../entities/giris_kalite_kontrol_form.dart';

abstract class IGirisKaliteKontrolRepository {
  Future<PagedResult<GirisKaliteKontrolForm>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<GirisKaliteKontrolForm>> getAll();
  Future<GirisKaliteKontrolForm> getById(int id);
  Future<int> create(GirisKaliteKontrolForm form);
  Future<void> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}
