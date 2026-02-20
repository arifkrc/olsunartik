import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/quality_approval_remote_datasource.dart';
import '../../data/repositories/quality_approval_repository_impl.dart';
import '../../domain/repositories/i_quality_approval_repository.dart';
import '../../domain/usecases/get_quality_approval_forms_usecase.dart';
import '../../domain/usecases/submit_quality_approval_form_usecase.dart';

// Data Source Provider
final qualityApprovalDataSourceProvider =
    Provider<QualityApprovalRemoteDataSource>((ref) {
      final dio = ref.watch(dioClientProvider);
      return QualityApprovalRemoteDataSource(dio);
    });

// Repository Provider
final qualityApprovalRepositoryProvider = Provider<IQualityApprovalRepository>((
  ref,
) {
  final dataSource = ref.watch(qualityApprovalDataSourceProvider);
  return QualityApprovalRepositoryImpl(dataSource);
});

// Use Case Providers
final getQualityApprovalFormsUseCaseProvider =
    Provider<GetQualityApprovalFormsUseCase>((ref) {
      final repository = ref.watch(qualityApprovalRepositoryProvider);
      return GetQualityApprovalFormsUseCase(repository);
    });

final submitQualityApprovalFormUseCaseProvider =
    Provider<SubmitQualityApprovalFormUseCase>((ref) {
      final repository = ref.watch(qualityApprovalRepositoryProvider);
      return SubmitQualityApprovalFormUseCase(repository);
    });
