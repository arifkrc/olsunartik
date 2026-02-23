import 'dart:io';
import '../../../../core/models/paged_result.dart';
import '../entities/fire_kayit_formu.dart';
import '../../data/models/fire_kayit_formu_dto.dart';

abstract class IFireKayitRepository {
  Future<PagedResult<FireKayitFormu>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
    int? vardiyaId,
  });
  Future<FireKayitFormu> getForm(int id);
  Future<int> createForm(FireKayitRequestDto data);
  Future<void> updateForm(int id, Map<String, dynamic> data);
  Future<void> deleteForm(int id);
  Future<String> uploadPhoto(int id, File file);
}
