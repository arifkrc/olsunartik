import '../entities/measurement_instrument.dart';
import '../repositories/i_measurement_instrument_repository.dart';

class GetMeasurementInstrumentsUseCase {
  final IMeasurementInstrumentRepository _repository;

  GetMeasurementInstrumentsUseCase(this._repository);

  Future<List<MeasurementInstrument>> call() {
    return _repository.getAll();
  }
}
