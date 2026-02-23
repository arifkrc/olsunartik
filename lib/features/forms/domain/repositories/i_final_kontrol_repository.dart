import '../../../../core/models/paged_result.dart';
import '../entities/final_kontrol_form.dart';
import '../../data/models/final_kontrol_form_dto.dart';

abstract class IFinalKontrolRepository {
  Future<PagedResult<FinalKontrolRecord>> getForms({
    int pageNumber = 1,
    int pageSize = 10,
    DateTime? startDate,
    DateTime? endDate,
    int? vardiyaId,
  });
  Future<List<FinalKontrolForm>> getAll();
  Future<FinalKontrolBulkResponseDto> createForm(FinalKontrolRequestDto requestDto);
  Future<void> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}
