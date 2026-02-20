import 'package:equatable/equatable.dart';
import '../../domain/production_counter.dart';

/// Production Counter State
/// Manages all state for production counter screens (final_kontrol, saf_b9, etc.)
class ProductionCounterState extends Equatable {
  final int total;
  final int paketlenen;
  final int rework;
  final int hurda;
  final int duzce; // For SAF B9
  final int almanya; // For SAF B9
  final List<ProductionLogEntry> logs;
  final String productName;
  final String productType;

  const ProductionCounterState({
    this.total = 0,
    this.paketlenen = 0,
    this.rework = 0,
    this.hurda = 0,
    this.duzce = 0,
    this.almanya = 0,
    this.logs = const [],
    this.productName = '',
    this.productType = '',
  });

  ProductionCounterState copyWith({
    int? total,
    int? paketlenen,
    int? rework,
    int? hurda,
    int? duzce,
    int? almanya,
    List<ProductionLogEntry>? logs,
    String? productName,
    String? productType,
  }) {
    return ProductionCounterState(
      total: total ?? this.total,
      paketlenen: paketlenen ?? this.paketlenen,
      rework: rework ?? this.rework,
      hurda: hurda ?? this.hurda,
      duzce: duzce ?? this.duzce,
      almanya: almanya ?? this.almanya,
      logs: logs ?? this.logs,
      productName: productName ?? this.productName,
      productType: productType ?? this.productType,
    );
  }

  @override
  List<Object?> get props => [
    total,
    paketlenen,
    rework,
    hurda,
    duzce,
    almanya,
    logs,
    productName,
    productType,
  ];
}
