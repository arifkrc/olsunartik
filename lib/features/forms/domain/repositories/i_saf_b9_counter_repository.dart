import '../../data/models/saf_b9_counter_entry_dto.dart';

abstract class ISafB9CounterRepository {
  Future<String> create(SAFBRequestDto request);
}
