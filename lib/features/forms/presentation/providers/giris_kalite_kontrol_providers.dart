import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/giris_kalite_kontrol_remote_datasource.dart';
import '../../data/repositories/giris_kalite_kontrol_repository_impl.dart';
import '../../domain/repositories/i_giris_kalite_kontrol_repository.dart';
import '../../domain/usecases/get_giris_kalite_kontrol_forms_usecase.dart';
import '../../domain/usecases/submit_giris_kalite_kontrol_form_usecase.dart';
import '../../domain/entities/giris_kalite_kontrol_form.dart';

final girisKaliteKontrolDataSourceProvider =
    Provider<GirisKaliteKontrolRemoteDataSource>((ref) {
      final dio = ref.watch(dioClientProvider);
      return GirisKaliteKontrolRemoteDataSource(dio);
    });

final girisKaliteKontrolRepositoryProvider =
    Provider<IGirisKaliteKontrolRepository>((ref) {
      final dataSource = ref.watch(girisKaliteKontrolDataSourceProvider);
      return GirisKaliteKontrolRepositoryImpl(dataSource);
    });

final getGirisKaliteKontrolFormsUseCaseProvider =
    Provider<GetGirisKaliteKontrolFormsUseCase>((ref) {
      final repository = ref.watch(girisKaliteKontrolRepositoryProvider);
      return GetGirisKaliteKontrolFormsUseCase(repository);
    });

final girisKaliteKontrolFormsProvider = FutureProvider<List<GirisKaliteKontrolForm>>((ref) async {
  final useCase = ref.watch(getGirisKaliteKontrolFormsUseCaseProvider);
  final result = await useCase.call(pageNumber: 1, pageSize: 1000);
  return result.items;
});

final submitGirisKaliteKontrolFormUseCaseProvider =
    Provider<SubmitGirisKaliteKontrolFormUseCase>((ref) {
      final repository = ref.watch(girisKaliteKontrolRepositoryProvider);
      return SubmitGirisKaliteKontrolFormUseCase(repository);
    });
