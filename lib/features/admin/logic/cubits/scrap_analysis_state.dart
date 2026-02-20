part of 'scrap_analysis_cubit.dart';

class ScrapAnalysisState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<ScrapData> scrapData;
  final DateTime analysisStartDate;
  final DateTime analysisEndDate;
  final DateTime backendStartDate;
  final DateTime backendEndDate;

  const ScrapAnalysisState({
    this.isLoading = false,
    this.error,
    this.scrapData = const [],
    required this.analysisStartDate,
    required this.analysisEndDate,
    required this.backendStartDate,
    required this.backendEndDate,
  });

  factory ScrapAnalysisState.initial() {
    final now = DateTime.now();
    return ScrapAnalysisState(
      analysisStartDate: now,
      analysisEndDate: now,
      backendStartDate: now,
      backendEndDate: now,
    );
  }

  ScrapAnalysisState copyWith({
    bool? isLoading,
    String? error,
    List<ScrapData>? scrapData,
    DateTime? analysisStartDate,
    DateTime? analysisEndDate,
    DateTime? backendStartDate,
    DateTime? backendEndDate,
  }) {
    return ScrapAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      scrapData: scrapData ?? this.scrapData,
      analysisStartDate: analysisStartDate ?? this.analysisStartDate,
      analysisEndDate: analysisEndDate ?? this.analysisEndDate,
      backendStartDate: backendStartDate ?? this.backendStartDate,
      backendEndDate: backendEndDate ?? this.backendEndDate,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    scrapData,
    analysisStartDate,
    analysisEndDate,
    backendStartDate,
    backendEndDate,
  ];
}

class ScrapData {
  final String factory; // D2, D3, FRENBU
  final String productType; // Disk, Kampana, Porya
  final String productCode;
  final int productionQty;
  final int scrapQty;
  final String defectReason; // Hata nedeni

  ScrapData({
    required this.factory,
    required this.productType,
    required this.productCode,
    required this.productionQty,
    required this.scrapQty,
    this.defectReason = '',
  });

  double get rate => productionQty > 0 ? (scrapQty / productionQty) * 100 : 0;
}
