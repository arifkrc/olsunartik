import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_management_dtos.dart';

class UserManagementRemoteDataSource {
  final Dio dio;

  UserManagementRemoteDataSource({required this.dio});

  Future<PaginatedResponse<KullaniciDto>> getUsers(
      {int pageNumber = 1, int pageSize = 20}) async {
    final response = await dio.get(
      '${ApiConstants.apiBase}/kullanici',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      (item) => KullaniciDto.fromJson(item as Map<String, dynamic>),
    );
  }

  Future<KullaniciDto> getUserDetails(int id) async {
    final response = await dio.get('${ApiConstants.apiBase}/kullanici/$id');
    // Ensure we parse the 'data' field. Response is { success: true, data: { ... } }
    final dynamic data = response.data['data'] ?? response.data;
    return KullaniciDto.fromJson(data as Map<String, dynamic>);
  }

  Future<KullaniciDto> updateAccount(
      int id, UpdateAccountRequest request) async {
    final response = await dio.put(
      '${ApiConstants.apiBase}/kullanici/$id',
      data: request.toJson(),
    );
    final dynamic data = response.data['data'] ?? response.data;
    return KullaniciDto.fromJson(data as Map<String, dynamic>);
  }

  Future<KullaniciDto> updatePersonnel(
      int id, UpdatePersonnelRequest request) async {
    final response = await dio.put(
      '${ApiConstants.apiBase}/lookup/personeller/$id',
      data: request.toJson(),
    );
    final dynamic data = response.data['data'] ?? response.data;
    return KullaniciDto.fromJson(data as Map<String, dynamic>);
  }

  Future<void> changePassword(int id, ChangePasswordRequest request) async {
    await dio.put(
      '${ApiConstants.apiBase}/kullanici/$id/parola',
      data: request.toJson(),
    );
  }

  Future<void> deleteUser(KullaniciDto user) async {
    // Soft delete using PUT request with specialized flat payload
    await dio.put(
      '${ApiConstants.apiBase}/kullanici/${user.id}',
      data: {
        'kullaniciAdi': user.kullaniciAdi,
        'hesapSeviyesi': user.hesapSeviyesi,
        'isActive': false,
        'personelId': user.personelId ?? 0,
      },
    );
  }
}
