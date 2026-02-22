import '../entities/final_kontrol_form.dart';
import '../../data/models/final_kontrol_form_dto.dart';

abstract class IFinalKontrolRepository {
  Future<List<FinalKontrolForm>> getAll();
  Future<List<FinalKontrolForm>> getForms({DateTime? date});
  Future<FinalKontrolBulkResponseDto> createForm(FinalKontrolRequestDto requestDto);
  Future<void> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}
