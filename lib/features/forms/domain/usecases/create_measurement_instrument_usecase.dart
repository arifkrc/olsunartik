import '../entities/measurement_instrument.dart';
import '../repositories/i_measurement_instrument_repository.dart';

class CreateMeasurementInstrumentUseCase {
  final IMeasurementInstrumentRepository _repository;

  CreateMeasurementInstrumentUseCase(this._repository);

  Future<int> call(MeasurementInstrument instrument) {
    return _repository.create(instrument);
  }
}
