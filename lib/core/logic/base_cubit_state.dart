import 'package:equatable/equatable.dart';

/// Base Cubit State for common state patterns
/// All feature-specific states should extend from this
abstract class BaseCubitState extends Equatable {
  const BaseCubitState();

  @override
  List<Object?> get props => [];
}

/// Initial state - used when Cubit is first created
class InitialState extends BaseCubitState {
  const InitialState();
}

/// Loading state - used during async operations
class LoadingState extends BaseCubitState {
  const LoadingState();
}

/// Loaded state - used when data is successfully loaded
class LoadedState<T> extends BaseCubitState {
  final T data;

  const LoadedState(this.data);

  @override
  List<Object?> get props => [data];
}

/// Error state - used when an error occurs
class ErrorState extends BaseCubitState {
  final String message;
  final dynamic error;

  const ErrorState(this.message, [this.error]);

  @override
  List<Object?> get props => [message, error];
}

/// Success state - used for successful operations without data
class SuccessState extends BaseCubitState {
  final String? message;

  const SuccessState([this.message]);

  @override
  List<Object?> get props => [message];
}
