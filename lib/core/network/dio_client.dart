import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';
import 'token_storage.dart';
import 'interceptors/auth_interceptor.dart';

part 'dio_client.g.dart';

@riverpod
Dio dioClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final tokenStorage = ref.watch(tokenStorageProvider);
  dio.interceptors.add(AuthInterceptor(tokenStorage));
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
}
