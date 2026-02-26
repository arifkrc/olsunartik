import 'package:dio/dio.dart';
import '../../../../core/network/models/api_result.dart';
import '../../../../core/error_handler.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../datasources/user_management_remote_datasource.dart';
import '../models/user_management_dtos.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementRemoteDataSource remoteDataSource;

  UserManagementRepositoryImpl({required this.remoteDataSource});

  ApiResult<T> _handleError<T>(dynamic e) {
    if (e is DioException &&
        e.response?.data != null &&
        e.response?.data is Map<String, dynamic>) {
      try {
        final apiResult = ApiResult.fromJson(
            e.response!.data as Map<String, dynamic>, null);
        return ApiResult<T>(
            success: false, message: resolveErrorMessage(apiResult));
      } catch (_) {
        return ApiResult<T>(success: false, message: e.message ?? 'Ağ hatası');
      }
    }
    return ApiResult<T>(success: false, message: e.toString());
  }

  @override
  Future<ApiResult<PaginatedResponse<KullaniciDto>>> getUsers(
      {int pageNumber = 1, int pageSize = 20}) async {
    try {
      final response = await remoteDataSource.getUsers(
          pageNumber: pageNumber, pageSize: pageSize);
      return ApiResult(success: true, data: response);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<ApiResult<KullaniciDto>> getUserDetails(int id) async {
    try {
      final response = await remoteDataSource.getUserDetails(id);
      return ApiResult(success: true, data: response);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<ApiResult<KullaniciDto>> updateAccount(
      int id, UpdateAccountRequest request) async {
    try {
      final response = await remoteDataSource.updateAccount(id, request);
      return ApiResult(success: true, data: response);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<ApiResult<KullaniciDto>> updatePersonnel(
      int id, UpdatePersonnelRequest request) async {
    try {
      final response = await remoteDataSource.updatePersonnel(id, request);
      return ApiResult(success: true, data: response);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<ApiResult<void>> changePassword(
      int id, ChangePasswordRequest request) async {
    try {
      await remoteDataSource.changePassword(id, request);
      return ApiResult(success: true, data: null);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<ApiResult<void>> deleteUser(KullaniciDto user) async {
    try {
      await remoteDataSource.deleteUser(user);
      return ApiResult(success: true, data: null);
    } catch (e) {
      return _handleError(e);
    }
  }
}
