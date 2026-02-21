import '../entities/rework_form.dart';

abstract class IReworkRepository {
  Future<List<ReworkForm>> getAll();
  Future<ReworkForm> getById(int id);
  Future<void> createBulk(List<ReworkForm> forms);
  Future<void> update(ReworkForm form);
  Future<void> delete(int id);
}
