import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/saf_b9_counter_remote_datasource.dart';
import '../../data/repositories/saf_b9_counter_repository_impl.dart';
import '../../domain/repositories/i_saf_b9_counter_repository.dart';
import '../../domain/usecases/submit_saf_b9_counter_entry_usecase.dart';

final safB9CounterDataSourceProvider = Provider<SafB9CounterRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioClientProvider);
  return SafB9CounterRemoteDataSource(dio);
});

final safB9CounterRepositoryProvider = Provider<ISafB9CounterRepository>((ref) {
  final dataSource = ref.watch(safB9CounterDataSourceProvider);
  return SafB9CounterRepositoryImpl(dataSource);
});

final submitSafB9CounterEntryUseCaseProvider =
    Provider<SubmitSafB9CounterEntryUseCase>((ref) {
      final repository = ref.watch(safB9CounterRepositoryProvider);
      return SubmitSafB9CounterEntryUseCase(repository);
    });
