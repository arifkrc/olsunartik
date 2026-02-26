import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/paged_result.dart';
import '../../../forms/presentation/providers/quality_approval_providers.dart';
import '../../../forms/presentation/providers/final_kontrol_providers.dart';
import '../../../forms/presentation/providers/fire_kayit_providers.dart';
import '../../../forms/presentation/providers/rework_providers.dart';
import '../../../forms/presentation/providers/giris_kalite_kontrol_providers.dart';
import '../../../forms/presentation/providers/palet_giris_providers.dart';
import '../../../forms/presentation/providers/saf_b9_counter_providers.dart';

class ReportFilter {
  final String type;
  final DateTime date;
  final int? vardiyaId;
  final int pageNumber;
  final int pageSize;

  ReportFilter({
    required this.type,
    required this.date,
    this.vardiyaId,
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  ReportFilter copyWith({
    String? type,
    DateTime? date,
    int? vardiyaId,
    int? pageNumber,
    int? pageSize,
  }) {
    return ReportFilter(
      type: type ?? this.type,
      date: date ?? this.date,
      vardiyaId: vardiyaId ?? this.vardiyaId,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportFilter &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          date == other.date &&
          vardiyaId == other.vardiyaId &&
          pageNumber == other.pageNumber &&
          pageSize == other.pageSize;

  @override
  int get hashCode =>
      type.hashCode ^
      date.hashCode ^
      vardiyaId.hashCode ^
      pageNumber.hashCode ^
      pageSize.hashCode;
}

class ReportFilterNotifier extends Notifier<ReportFilter> {
  @override
  ReportFilter build() => ReportFilter(
    type: 'KaliteOnay',
    date: DateTime.now(),
  );

  void update(ReportFilter Function(ReportFilter) cb) {
    state = cb(state);
  }
}

final reportFilterProvider = NotifierProvider<ReportFilterNotifier, ReportFilter>(ReportFilterNotifier.new);

final reportListProvider = FutureProvider<PagedResult<dynamic>>((ref) async {
  final filter = ref.watch(reportFilterProvider);
  
  // Calculate start and end of the selected day
  final startDate = DateTime(filter.date.year, filter.date.month, filter.date.day, 0, 0, 0);
  final endDate = DateTime(filter.date.year, filter.date.month, filter.date.day, 23, 59, 59);

  switch (filter.type) {
    case 'KaliteOnay':
      return await ref.read(qualityApprovalRepositoryProvider).getForms(
        pageNumber: filter.pageNumber,
        pageSize: filter.pageSize,
        startDate: startDate,
        endDate: endDate,
        vardiyaId: filter.vardiyaId,
      );
    case 'FinalKontrol':
      return await ref.read(finalKontrolRepositoryProvider).getForms(
        pageNumber: filter.pageNumber,
        pageSize: filter.pageSize,
        startDate: startDate,
        endDate: endDate,
        vardiyaId: filter.vardiyaId,
      );
    case 'FireKayitFormu':
      return await ref.read(fireKayitRepositoryProvider).getForms(
        pageNumber: filter.pageNumber,
        pageSize: filter.pageSize,
        startDate: startDate,
        endDate: endDate,
        vardiyaId: filter.vardiyaId,
      );
    case 'Rework':
      return await ref.read(reworkRepositoryProvider).getForms(
        pageNumber: filter.pageNumber,
        pageSize: filter.pageSize,
        startDate: startDate,
        endDate: endDate,
        vardiyaId: filter.vardiyaId,
      );
    case 'GirisKalite':
      return await ref.read(girisKaliteKontrolRepositoryProvider).getForms(
        pageNumber: filter.pageNumber,
        pageSize: filter.pageSize,
        startDate: startDate,
        endDate: endDate,
      );
    case 'PaletGiris':
      return await ref.read(paletGirisRepositoryProvider).getForms(
        pageNumber: filter.pageNumber,
        pageSize: filter.pageSize,
        startDate: startDate,
        endDate: endDate,
      );
    case 'SafB9':
      return await ref.read(safB9CounterRepositoryProvider).getForms(
        pageNumber: filter.pageNumber,
        pageSize: filter.pageSize,
        startDate: startDate,
        endDate: endDate,
        vardiyaId: filter.vardiyaId,
      );
    default:
      throw Exception('Bilinmeyen form tipi: ${filter.type}');
  }
});
