import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/production_counter.dart';
import 'production_counter_state.dart';

/// Production Counter Cubit
/// Manages production counter state and business logic
/// Used by final_kontrol_screen, saf_b9_counter_screen, etc.
class ProductionCounterCubit extends Cubit<ProductionCounterState> {
  ProductionCounterCubit() : super(const ProductionCounterState());

  /// Update product information
  void setProductInfo(String name, String type) {
    emit(state.copyWith(productName: name, productType: type));
  }

  /// Increment paketlenen counter
  void incrementPaketlenen(int amount) {
    emit(
      state.copyWith(
        paketlenen: state.paketlenen + amount,
        total: state.total + amount,
      ),
    );
    _addLog('paketlenen', amount);
  }

  /// Increment rework counter
  void incrementRework(int amount) {
    emit(
      state.copyWith(
        rework: state.rework + amount,
        total: state.total + amount,
      ),
    );
    _addLog('rework', amount);
  }

  /// Increment hurda counter with reason
  void incrementHurda(int amount, int reasonId, String reason) {
    emit(
      state.copyWith(hurda: state.hurda + amount, total: state.total + amount),
    );
    _addLog('hurda', amount, reasonId: reasonId, reason: reason);
  }

  /// Increment Düzce counter (for SAF B9)
  void incrementDuzce(int amount) {
    emit(
      state.copyWith(duzce: state.duzce + amount, total: state.total + amount),
    );
    _addLog('duzce', amount);
  }

  /// Increment Almanya counter (for SAF B9)
  void incrementAlmanya(int amount) {
    emit(
      state.copyWith(
        almanya: state.almanya + amount,
        total: state.total + amount,
      ),
    );
    _addLog('almanya', amount);
  }

  /// Add log entry
  void _addLog(String type, int amount, {int? reasonId, String? reason}) {
    final log = ProductionLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      actionType: type,
      quantity: amount,
      scrapReasonId: reasonId,
      scrapReason: reason,
    );
    emit(state.copyWith(logs: [...state.logs, log]));
  }

  /// Undo last operation
  void undoLast() {
    if (state.logs.isEmpty) return;

    final lastLog = state.logs.last;
    final updatedLogs = state.logs.sublist(0, state.logs.length - 1);

    // Reverse the operation
    int newTotal = state.total - lastLog.quantity;
    int newPaketlenen = state.paketlenen;
    int newRework = state.rework;
    int newHurda = state.hurda;
    int newDuzce = state.duzce;
    int newAlmanya = state.almanya;

    switch (lastLog.actionType) {
      case 'paketlenen':
        newPaketlenen -= lastLog.quantity;
        break;
      case 'rework':
        newRework -= lastLog.quantity;
        break;
      case 'hurda':
        newHurda -= lastLog.quantity;
        break;
      case 'duzce':
        newDuzce -= lastLog.quantity;
        break;
      case 'almanya':
        newAlmanya -= lastLog.quantity;
        break;
    }

    emit(
      state.copyWith(
        total: newTotal,
        paketlenen: newPaketlenen,
        rework: newRework,
        hurda: newHurda,
        duzce: newDuzce,
        almanya: newAlmanya,
        logs: updatedLogs,
      ),
    );
  }

  /// Clear all counters
  void clearAll() {
    emit(const ProductionCounterState());
  }
}
