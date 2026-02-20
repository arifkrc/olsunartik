import '../../domain/entities/vardiya.dart';
import '../../domain/entities/operasyon.dart';
import '../../domain/entities/tezgah.dart';
import '../../domain/entities/bolge.dart';
import '../../domain/entities/ret_kodu.dart';
import '../../domain/repositories/i_lookup_repository.dart';
import '../datasources/lookup_remote_datasource.dart';

class LookupRepositoryImpl implements ILookupRepository {
  final LookupRemoteDataSource _remoteDataSource;

  LookupRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Vardiya>> getVardiyalar() async {
    return await _remoteDataSource.getVardiyalar();
  }

  @override
  Future<List<Operasyon>> getOperasyonlar() async {
    return await _remoteDataSource.getOperasyonlar();
  }

  @override
  Future<List<Tezgah>> getTezgahlar() async {
    return await _remoteDataSource.getTezgahlar();
  }

  @override
  Future<List<Bolge>> getBolgeler() async {
    return await _remoteDataSource.getBolgeler();
  }

  @override
  Future<List<RetKodu>> getRetKodlari() async {
    return await _remoteDataSource.getRetKodlari();
  }
}
