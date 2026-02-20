import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/fire_kayit_remote_datasource.dart';
import '../../data/repositories/fire_kayit_repository_impl.dart';
import '../../domain/repositories/i_fire_kayit_repository.dart';
import '../../domain/usecases/create_fire_kayit_form_usecase.dart';
import '../../domain/usecases/get_fire_kayit_forms_usecase.dart';
import '../../domain/entities/fire_kayit_formu.dart';

// DataSource Provider
final fireKayitRemoteDataSourceProvider = Provider<FireKayitRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioClientProvider);
  return FireKayitRemoteDataSource(dio);
});

// Repository Provider
final fireKayitRepositoryProvider = Provider<IFireKayitRepository>((ref) {
  final dataSource = ref.watch(fireKayitRemoteDataSourceProvider);
  return FireKayitRepositoryImpl(dataSource);
});

// UseCase Providers
final getFireKayitFormsUseCaseProvider = Provider<GetFireKayitFormsUseCase>((
  ref,
) {
  final repository = ref.watch(fireKayitRepositoryProvider);
  return GetFireKayitFormsUseCase(repository);
});

final createFireKayitFormUseCaseProvider = Provider<CreateFireKayitFormUseCase>(
  (ref) {
    final repository = ref.watch(fireKayitRepositoryProvider);
    return CreateFireKayitFormUseCase(repository);
  },
);

// Fire Kayıt Listesi Provider
final fireKayitFormsProvider = FutureProvider<List<FireKayitFormu>>((
  ref,
) async {
  final useCase = ref.watch(getFireKayitFormsUseCaseProvider);
  // UseCase call ile çalışıyor, tüm kayıtlar için büyük pageSize
  return await useCase.call(pageNumber: 1, pageSize: 1000);
});
