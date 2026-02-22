import '../../data/models/saf_b9_counter_entry_dto.dart';

abstract class ISafB9CounterRepository {
  Future<String> create(SAFBRequestDto request);
  Future<void> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}
