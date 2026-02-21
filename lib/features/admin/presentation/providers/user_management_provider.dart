import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/user_management_remote_datasource.dart';
import '../../data/models/user_management_dtos.dart';
import '../../data/repositories/user_management_repository_impl.dart';
import '../../domain/repositories/user_management_repository.dart';

// Repository Provider
final userManagementRepositoryProvider = Provider<UserManagementRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final remoteDataSource = UserManagementRemoteDataSource(dio: dioClient);
  return UserManagementRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Pagination State
class UserPaginationState {
  final int pageNumber;
  final int pageSize;

  UserPaginationState({required this.pageNumber, required this.pageSize});

  UserPaginationState copyWith({int? pageNumber, int? pageSize}) {
    return UserPaginationState(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class UserPaginationNotifier extends Notifier<UserPaginationState> {
  @override
  UserPaginationState build() {
    return UserPaginationState(pageNumber: 1, pageSize: 20);
  }

  void setPage(int page) {
    state = state.copyWith(pageNumber: page);
  }
}

final userPaginationProvider = NotifierProvider<UserPaginationNotifier, UserPaginationState>(
  () => UserPaginationNotifier(),
);

// List Provider
final usersListProvider = FutureProvider<PaginatedResponse<KullaniciDto>>((ref) async {
  final repository = ref.watch(userManagementRepositoryProvider);
  final pagination = ref.watch(userPaginationProvider);

  final result = await repository.getUsers(
    pageNumber: pagination.pageNumber,
    pageSize: pagination.pageSize,
  );

  if (result.success) return result.data!;
  throw Exception(result.message ?? 'Unknown error');
});

// Single Record fetcher
final userDetailsProvider = FutureProvider.family<KullaniciDto, int>((ref, id) async {
  final repository = ref.watch(userManagementRepositoryProvider);
  final result = await repository.getUserDetails(id);
  
  if (result.success) return result.data!;
  throw Exception(result.message ?? 'Unknown error');
});

// Permission levels helper (Mapped to backend enums)
// 0=SuperAdmin, 1=Admin, 2=Yonetici, 3=Kullanici, 4=Misafir
final permissionLevels = {
  0: 'Süper Admin',
  1: 'Admin',
  2: 'Yönetici',
  3: 'Kullanıcı',
  4: 'Misafir',
};
