import '../entities/auth_token.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthToken> call(String kullaniciAdi, String parola) {
    return _repository.login(kullaniciAdi, parola);
  }
}
