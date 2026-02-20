import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/final_kontrol_remote_datasource.dart';
import '../../data/repositories/final_kontrol_repository_impl.dart';
import '../../domain/repositories/i_final_kontrol_repository.dart';
import '../../domain/usecases/get_final_kontrol_forms_usecase.dart';
import '../../domain/usecases/submit_final_kontrol_form_usecase.dart';

final finalKontrolDataSourceProvider = Provider<FinalKontrolRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioClientProvider);
  return FinalKontrolRemoteDataSource(dio);
});

final finalKontrolRepositoryProvider = Provider<IFinalKontrolRepository>((ref) {
  final dataSource = ref.watch(finalKontrolDataSourceProvider);
  return FinalKontrolRepositoryImpl(dataSource);
});

final getFinalKontrolFormsUseCaseProvider =
    Provider<GetFinalKontrolFormsUseCase>((ref) {
      final repository = ref.watch(finalKontrolRepositoryProvider);
      return GetFinalKontrolFormsUseCase(repository);
    });

final submitFinalKontrolFormUseCaseProvider =
    Provider<SubmitFinalKontrolFormUseCase>((ref) {
      final repository = ref.watch(finalKontrolRepositoryProvider);
      return SubmitFinalKontrolFormUseCase(repository);
    });
