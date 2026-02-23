import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/rework_remote_datasource.dart';
import '../../data/repositories/rework_repository_impl.dart';
import '../../domain/repositories/i_rework_repository.dart';
import '../../domain/usecases/get_rework_forms_usecase.dart';
import '../../domain/usecases/submit_rework_form_usecase.dart';
import '../../domain/entities/rework_form.dart'; // Added this import for ReworkForm

final reworkDataSourceProvider = Provider<ReworkRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ReworkRemoteDataSource(dio);
});

final reworkFormsProvider = FutureProvider<List<ReworkForm>>((ref) async {
  final useCase = ref.watch(getReworkFormsUseCaseProvider);
  final result = await useCase.call(pageNumber: 1, pageSize: 1000);
  return result.items;
});

final reworkRepositoryProvider = Provider<IReworkRepository>((ref) {
  final dataSource = ref.watch(reworkDataSourceProvider);
  return ReworkRepositoryImpl(dataSource);
});

final getReworkFormsUseCaseProvider = Provider<GetReworkFormsUseCase>((ref) {
  final repository = ref.watch(reworkRepositoryProvider);
  return GetReworkFormsUseCase(repository);
});

final submitReworkFormUseCaseProvider = Provider<SubmitReworkFormUseCase>((
  ref,
) {
  final repository = ref.watch(reworkRepositoryProvider);
  return SubmitReworkFormUseCase(repository);
});
