import '../entities/palet_giris_form.dart';

abstract class IPaletGirisRepository {
  Future<List<PaletGirisForm>> getAll();
  Future<PaletGirisForm> getById(int id);
  Future<int> create(PaletGirisForm form);
  Future<void> update(PaletGirisForm form);
  Future<void> delete(int id);
}
