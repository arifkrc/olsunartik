import '../entities/giris_kalite_kontrol_form.dart';

abstract class IGirisKaliteKontrolRepository {
  Future<List<GirisKaliteKontrolForm>> getAll();
  Future<GirisKaliteKontrolForm> getById(int id);
  Future<int> create(GirisKaliteKontrolForm form);
  Future<void> update(GirisKaliteKontrolForm form);
  Future<void> delete(int id);
}
