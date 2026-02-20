import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    required DateTime selectedDate,
    @Default([]) List<String> birthdaysToday,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _HomeState;

  factory HomeState.initial() => HomeState(selectedDate: DateTime.now());
}
