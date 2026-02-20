import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/analytics_remote_datasource.dart';
import '../../data/models/analytics_range_dto.dart';

final analyticsRemoteDataSourceProvider = Provider<AnalyticsRemoteDataSource>((ref) {
  return AnalyticsRemoteDataSource(ref.watch(dioClientProvider));
});

/// Query model for parameterized provider
class AnalyticsQuery {
  final DateTime startDate;
  final DateTime endDate;

  const AnalyticsQuery({required this.startDate, required this.endDate});

  @override
  bool operator ==(Object other) =>
      other is AnalyticsQuery &&
      other.startDate == startDate &&
      other.endDate == endDate;

  @override
  int get hashCode => Object.hash(startDate, endDate);
}

final analyticsRangeProvider =
    FutureProvider.family<AnalyticsRangeDto, AnalyticsQuery>((ref, query) async {
  final dataSource = ref.watch(analyticsRemoteDataSourceProvider);
  return dataSource.getRange(startDate: query.startDate, endDate: query.endDate);
});
