import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/measurement_instrument_remote_datasource.dart';
import '../../data/repositories/measurement_instrument_repository_impl.dart';
import '../../domain/repositories/i_measurement_instrument_repository.dart';
import '../../domain/usecases/get_measurement_instruments_usecase.dart';
import '../../domain/usecases/create_measurement_instrument_usecase.dart';

final measurementInstrumentDataSourceProvider =
    Provider<MeasurementInstrumentRemoteDataSource>((ref) {
      final dio = ref.watch(dioClientProvider);
      return MeasurementInstrumentRemoteDataSource(dio);
    });

final measurementInstrumentRepositoryProvider =
    Provider<IMeasurementInstrumentRepository>((ref) {
      final dataSource = ref.watch(measurementInstrumentDataSourceProvider);
      return MeasurementInstrumentRepositoryImpl(dataSource);
    });

final getMeasurementInstrumentsUseCaseProvider =
    Provider<GetMeasurementInstrumentsUseCase>((ref) {
      final repository = ref.watch(measurementInstrumentRepositoryProvider);
      return GetMeasurementInstrumentsUseCase(repository);
    });

final createMeasurementInstrumentUseCaseProvider =
    Provider<CreateMeasurementInstrumentUseCase>((ref) {
      final repository = ref.watch(measurementInstrumentRepositoryProvider);
      return CreateMeasurementInstrumentUseCase(repository);
    });
