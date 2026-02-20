import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/ret_kod_remote_datasource.dart';
import '../domain/entities/ret_kod.dart';
import '../network/dio_client.dart';

/// RetKod DataSource Provider
final retKodRemoteDataSourceProvider = Provider<RetKodRemoteDataSource>((ref) {
  return RetKodRemoteDataSource(ref.watch(dioClientProvider));
});

/// Tüm ret kodlarını backend'den çeken ve cache'leyen provider
final retKodlariProvider = FutureProvider<List<RetKod>>((ref) async {
  return ref.watch(retKodRemoteDataSourceProvider).getAll();
});
