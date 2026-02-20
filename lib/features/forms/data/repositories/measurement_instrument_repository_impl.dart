import '../../domain/entities/measurement_instrument.dart';
import '../../domain/repositories/i_measurement_instrument_repository.dart';
import '../datasources/measurement_instrument_remote_datasource.dart';
import '../models/measurement_instrument_dto.dart';

class MeasurementInstrumentRepositoryImpl
    implements IMeasurementInstrumentRepository {
  final MeasurementInstrumentRemoteDataSource _remoteDataSource;

  MeasurementInstrumentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<MeasurementInstrument>> getAll() async {
    final dtos = await _remoteDataSource.getAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<MeasurementInstrument> getById(int id) async {
    final dto = await _remoteDataSource.getById(id);
    return dto.toEntity();
  }

  @override
  Future<int> create(MeasurementInstrument instrument) async {
    final dto = MeasurementInstrumentDto(
      id: instrument.id,
      ad: instrument.ad,
      kod: instrument.kod,
      tip: instrument.tip,
      sonKalibrasyon: instrument.sonKalibrasyon,
      gelecekKalibrasyon: instrument.gelecekKalibrasyon,
      durum: instrument.durum,
      aciklama: instrument.aciklama,
    );
    return await _remoteDataSource.create(dto.toJson());
  }

  @override
  Future<void> update(MeasurementInstrument instrument) async {
    final dto = MeasurementInstrumentDto(
      id: instrument.id,
      ad: instrument.ad,
      kod: instrument.kod,
      tip: instrument.tip,
      sonKalibrasyon: instrument.sonKalibrasyon,
      gelecekKalibrasyon: instrument.gelecekKalibrasyon,
      durum: instrument.durum,
      aciklama: instrument.aciklama,
    );
    await _remoteDataSource.update(instrument.id!, dto.toJson());
  }

  @override
  Future<void> delete(int id) async {
    await _remoteDataSource.delete(id);
  }
}
