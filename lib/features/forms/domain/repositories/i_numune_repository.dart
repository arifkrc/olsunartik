import '../entities/numune_form.dart';

abstract class INumuneRepository {
  Future<List<NumuneForm>> getAll();
  Future<NumuneForm> getById(int id);
  Future<int> create(NumuneForm form);
  Future<void> update(NumuneForm form);
  Future<void> delete(int id);
}
