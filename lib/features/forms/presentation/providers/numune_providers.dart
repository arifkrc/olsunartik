import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/numune_remote_datasource.dart';
import '../../data/repositories/numune_repository_impl.dart';
import '../../domain/repositories/i_numune_repository.dart';
import '../../domain/usecases/get_numune_forms_usecase.dart';
import '../../domain/usecases/submit_numune_form_usecase.dart';

final numuneDataSourceProvider = Provider<NumuneRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return NumuneRemoteDataSource(dio);
});

final numuneRepositoryProvider = Provider<INumuneRepository>((ref) {
  final dataSource = ref.watch(numuneDataSourceProvider);
  return NumuneRepositoryImpl(dataSource);
});

final getNumuneFormsUseCaseProvider = Provider<GetNumuneFormsUseCase>((ref) {
  final repository = ref.watch(numuneRepositoryProvider);
  return GetNumuneFormsUseCase(repository);
});

final submitNumuneFormUseCaseProvider = Provider<SubmitNumuneFormUseCase>((
  ref,
) {
  final repository = ref.watch(numuneRepositoryProvider);
  return SubmitNumuneFormUseCase(repository);
});
