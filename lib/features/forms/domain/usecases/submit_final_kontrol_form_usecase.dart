import '../repositories/i_final_kontrol_repository.dart';
import '../../data/models/final_kontrol_form_dto.dart';

class SubmitFinalKontrolFormUseCase {
  final IFinalKontrolRepository _repository;

  SubmitFinalKontrolFormUseCase(this._repository);

  Future<FinalKontrolBulkResponseDto> call(FinalKontrolRequestDto requestDto) {
    return _repository.createForm(requestDto);
  }
}
