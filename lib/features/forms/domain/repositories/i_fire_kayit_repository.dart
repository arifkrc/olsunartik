import 'dart:io';
import '../entities/fire_kayit_formu.dart';
import '../../data/models/fire_kayit_formu_dto.dart';

abstract class IFireKayitRepository {
  Future<List<FireKayitFormu>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
  });
  Future<FireKayitFormu> getForm(int id);
  Future<int> createForm(FireKayitRequestDto data);
  Future<void> updateForm(int id, Map<String, dynamic> data);
  Future<void> deleteForm(int id);
  Future<String> uploadPhoto(int id, File file);
}
