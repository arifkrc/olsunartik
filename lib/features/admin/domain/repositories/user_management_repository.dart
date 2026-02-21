import '../../../../core/network/models/api_result.dart';
import '../../data/models/user_management_dtos.dart';

abstract class UserManagementRepository {
  Future<ApiResult<PaginatedResponse<KullaniciDto>>> getUsers({
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<ApiResult<KullaniciDto>> getUserDetails(int id);

  Future<ApiResult<KullaniciDto>> updateAccount(
      int id, UpdateAccountRequest request);

  Future<ApiResult<KullaniciDto>> updatePersonnel(
      int id, UpdatePersonnelRequest request);

  Future<ApiResult<void>> changePassword(
      int id, ChangePasswordRequest request);

  Future<ApiResult<void>> deleteUser(int id);
}
