import '../entities/vardiya.dart';
import '../entities/operasyon.dart';
import '../entities/tezgah.dart';
import '../entities/bolge.dart';
import '../entities/ret_kodu.dart';

abstract class ILookupRepository {
  Future<List<Vardiya>> getVardiyalar();
  Future<List<Operasyon>> getOperasyonlar();
  Future<List<Tezgah>> getTezgahlar();
  Future<List<Bolge>> getBolgeler();
  Future<List<RetKodu>> getRetKodlari();
}
