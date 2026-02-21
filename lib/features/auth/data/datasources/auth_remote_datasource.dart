import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/auth_token_dto.dart';
import '../models/user_dto.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<AuthTokenDto> login(String kullaniciAdi, String parola) async {
    final response = await _dio.post(
      '${ApiConstants.authBase}/auth/login',
      data: {'kullaniciAdi': kullaniciAdi, 'parola': parola},
    );

    if (response.data['success'] == true) {
      return AuthTokenDto.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Login failed');
    }
  }

  Future<UserDto> register({
    required String kullaniciAdi,
    required String parola,
    required String hesapSeviyesi,
    int? personelId,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.authBase}/auth/register',
      data: {
        'kullaniciAdi': kullaniciAdi,
        'parola': parola,
        'hesapSeviyesi': hesapSeviyesi,
        'personelId': personelId,
      },
    );

    if (response.data['success'] == true) {
      return UserDto.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Registration failed');
    }
  }

  Future<UserDto> getCurrentUser() async {
    final response = await _dio.get('${ApiConstants.authBase}/auth/me');

    if (response.data['success'] == true) {
      return UserDto.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to get user');
    }
  }
}
