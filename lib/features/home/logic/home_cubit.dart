import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

/// Cubit for managing Home Screen state
/// Handles birthday checks and date selection
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState.initial()) {
    checkBirthdays();
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
    checkBirthdays();
  }

  Future<void> checkBirthdays() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Birthday check to be implemented with backend integration
      // This should fetch from database and check against selected date
      final birthdaysToday = <String>[];

      // Mock implementation - commented out for now
      // final today = state.selectedDate;
      // if (today.month == 1 && today.day == 15) {
      //   birthdaysToday.add('Furkan Yılmaz');
      // }

      emit(state.copyWith(birthdaysToday: birthdaysToday, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void refreshBirthdays() {
    checkBirthdays();
  }
}
