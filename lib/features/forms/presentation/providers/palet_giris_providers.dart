import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/palet_giris_remote_datasource.dart';
import '../../data/repositories/palet_giris_repository_impl.dart';
import '../../domain/repositories/i_palet_giris_repository.dart';
import '../../domain/usecases/get_palet_giris_forms_usecase.dart';
import '../../domain/usecases/submit_palet_giris_form_usecase.dart';

final paletGirisDataSourceProvider = Provider<PaletGirisRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioClientProvider);
  return PaletGirisRemoteDataSource(dio);
});

final paletGirisRepositoryProvider = Provider<IPaletGirisRepository>((ref) {
  final dataSource = ref.watch(paletGirisDataSourceProvider);
  return PaletGirisRepositoryImpl(dataSource);
});

final getPaletGirisFormsUseCaseProvider = Provider<GetPaletGirisFormsUseCase>((
  ref,
) {
  final repository = ref.watch(paletGirisRepositoryProvider);
  return GetPaletGirisFormsUseCase(repository);
});

final submitPaletGirisFormUseCaseProvider =
    Provider<SubmitPaletGirisFormUseCase>((ref) {
      final repository = ref.watch(paletGirisRepositoryProvider);
      return SubmitPaletGirisFormUseCase(repository);
    });
