import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../data/datasources/lookup_remote_datasource.dart';
import '../data/repositories/lookup_repository_impl.dart';
import '../domain/repositories/i_lookup_repository.dart';

// DataSource Provider
final lookupRemoteDataSourceProvider = Provider<LookupRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return LookupRemoteDataSource(dio);
});

// Repository Provider
final lookupRepositoryProvider = Provider<ILookupRepository>((ref) {
  final dataSource = ref.watch(lookupRemoteDataSourceProvider);
  return LookupRepositoryImpl(dataSource);
});

// Individual Lookup Providers (Cached)
final vardiyalarProvider = FutureProvider((ref) async {
  return await ref.watch(lookupRepositoryProvider).getVardiyalar();
});

final operasyonlarProvider = FutureProvider((ref) async {
  return await ref.watch(lookupRepositoryProvider).getOperasyonlar();
});

final tezgahlarProvider = FutureProvider((ref) async {
  return await ref.watch(lookupRepositoryProvider).getTezgahlar();
});

final bolgelerProvider = FutureProvider((ref) async {
  return await ref.watch(lookupRepositoryProvider).getBolgeler();
});

final retKodlariProvider = FutureProvider((ref) async {
  return await ref.watch(lookupRepositoryProvider).getRetKodlari();
});
