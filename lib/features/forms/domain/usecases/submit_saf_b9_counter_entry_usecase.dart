import '../../data/models/saf_b9_counter_entry_dto.dart';
import '../repositories/i_saf_b9_counter_repository.dart';

class SubmitSafB9CounterEntryUseCase {
  final ISafB9CounterRepository _repository;

  SubmitSafB9CounterEntryUseCase(this._repository);

  Future<String> call(SAFBRequestDto request) {
    return _repository.create(request);
  }
}
