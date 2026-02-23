import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/fire_analiz_remote_datasource.dart';
import '../../data/repositories/fire_analiz_repository_impl.dart';
import '../../domain/repositories/i_fire_analiz_repository.dart';

/// DataSource Provider
final fireAnalizRemoteDataSourceProvider = Provider<FireAnalizRemoteDataSource>((ref) {
  return FireAnalizRemoteDataSource(ref.watch(dioClientProvider));
});

/// Repository Provider
final fireAnalizRepositoryProvider = Provider<IFireAnalizRepository>((ref) {
  return FireAnalizRepositoryImpl(
    ref.watch(fireAnalizRemoteDataSourceProvider),
  );
});
