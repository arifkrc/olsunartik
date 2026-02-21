import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../features/auth/presentation/login_screen.dart';
import '../../navigation/navigator_key.dart';
import '../token_storage.dart';

class RateLimitException extends DioException {
  final String? retryAfterSeconds;
  
  RateLimitException({required super.requestOptions, this.retryAfterSeconds}) 
      : super(error: 'Rate limit exceeded. Retry after $retryAfterSeconds seconds.');
}

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  AuthInterceptor(this._tokenStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (['POST', 'PUT'].contains(options.method.toUpperCase())) {
      options.headers.putIfAbsent('X-Idempotency-Key', () => const Uuid().v4());
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.response?.statusCode) {
      case 401:
        _tokenStorage.clearToken();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        break;
      case 429:
        final retryAfter = err.response?.headers.value('Retry-After');
        handler.reject(RateLimitException(
          requestOptions: err.requestOptions, 
          retryAfterSeconds: retryAfter
        ));
        return;
    }
    super.onError(err, handler);
  }
}
