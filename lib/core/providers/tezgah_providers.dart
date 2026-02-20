import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/tezgah_remote_datasource.dart';
import '../domain/entities/tezgah.dart';
import '../network/dio_client.dart';

final tezgahRemoteDataSourceProvider = Provider<TezgahRemoteDataSource>((ref) {
  return TezgahRemoteDataSource(ref.watch(dioClientProvider));
});

final tezgahlarProvider = FutureProvider<List<Tezgah>>((ref) async {
  return ref.watch(tezgahRemoteDataSourceProvider).getAll();
});
