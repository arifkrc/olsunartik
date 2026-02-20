import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quality_approval_form.dart';
import '../../domain/usecases/submit_quality_approval_form_usecase.dart';
import 'quality_approval_state.dart';

/// Cubit for managing Quality Approval Form state
/// Follows BLoC pattern as per frontend standards
class QualityApprovalCubit extends Cubit<QualityApprovalState> {
  final SubmitQualityApprovalFormUseCase _submitUseCase;

  QualityApprovalCubit(this._submitUseCase)
    : super(QualityApprovalState.initial());

  void updateProductCode(int? id, String code) {
    emit(state.copyWith(productId: id, productCode: code));
  }

  void updateProductInfo(String? name, String? type) {
    emit(state.copyWith(productName: name, productType: type));
  }

  void updateAmount(int amount) {
    if (amount >= 1) {
      emit(state.copyWith(amount: amount));
    }
  }

  void incrementAmount() {
    emit(state.copyWith(amount: state.amount + 1));
  }

  void decrementAmount() {
    if (state.amount > 1) {
      emit(state.copyWith(amount: state.amount - 1));
    }
  }

  void updateComplianceStatus(bool isUygun) {
    emit(
      state.copyWith(
        isUygun: isUygun,
        rejectCode: isUygun ? null : state.rejectCode,
      ),
    );
  }

  void updateRejectCode(String? code) {
    emit(state.copyWith(rejectCode: code));
  }

  void updateDescription(String description) {
    emit(state.copyWith(description: description));
  }

  void updateDateTime(DateTime dateTime) {
    emit(state.copyWith(islemTarihi: dateTime));
  }

  Future<void> submitForm() async {
    if (state.productCode.isEmpty) {
      emit(state.copyWith(errorMessage: 'Ürün kodu gerekli'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final form = QualityApprovalForm(
        // Assuming id is null for new creation
        urunId: state.productId ?? 0, // Fallback eklenebilir
        urunKodu: state.productCode,
        urunAdi: state.productName ?? '',
        urunTuru: state.productType ?? '',
        adet: state.amount,
        isUygun: state.isUygun,
        retKoduId: state.rejectCode != null ? 1 : null, // Mapped temporarily
        aciklama: state.description,
        islemTarihi: state.islemTarihi,
      );

      await _submitUseCase.call(form);

      // Success - reset form
      emit(QualityApprovalState.initial());
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  void resetForm() {
    emit(QualityApprovalState.initial());
  }
}
