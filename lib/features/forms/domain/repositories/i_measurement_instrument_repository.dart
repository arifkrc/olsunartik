import '../entities/measurement_instrument.dart';

abstract class IMeasurementInstrumentRepository {
  Future<List<MeasurementInstrument>> getAll();
  Future<MeasurementInstrument> getById(int id);
  Future<int> create(MeasurementInstrument instrument);
  Future<void> update(MeasurementInstrument instrument);
  Future<void> delete(int id);
}
