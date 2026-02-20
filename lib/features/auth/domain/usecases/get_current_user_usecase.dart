import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class GetCurrentUserUseCase {
  final IAuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<User> call() {
    return _repository.getCurrentUser();
  }
}
