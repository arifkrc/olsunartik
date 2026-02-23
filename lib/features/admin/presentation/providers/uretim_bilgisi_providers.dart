import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/uretim_bilgisi_remote_datasource.dart';
import '../../data/repositories/uretim_bilgisi_repository_impl.dart';
import '../../domain/repositories/i_uretim_bilgisi_repository.dart';
import '../../domain/usecases/bulk_insert_uretim_bilgisi_usecase.dart';

/// DataSource Provider
final uretimBilgisiRemoteDataSourceProvider = Provider<UretimBilgisiRemoteDataSource>((ref) {
  return UretimBilgisiRemoteDataSource(ref.watch(dioClientProvider));
});

/// Repository Provider
final uretimBilgisiRepositoryProvider = Provider<IUretimBilgisiRepository>((ref) {
  return UretimBilgisiRepositoryImpl(
    ref.watch(uretimBilgisiRemoteDataSourceProvider),
  );
});

/// UseCase Provider
final bulkInsertUretimBilgisiUseCaseProvider = Provider<BulkInsertUretimBilgisiUseCase>((ref) {
  return BulkInsertUretimBilgisiUseCase(
    ref.watch(uretimBilgisiRepositoryProvider),
  );
});
