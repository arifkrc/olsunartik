import '../entities/auth_token.dart';
import '../entities/user.dart';

abstract class IAuthRepository {
  Future<AuthToken> login(String kullaniciAdi, String parola);
  Future<User> register({
    required String kullaniciAdi,
    required String parola,
    required int hesapSeviyesi,
    int? personelId,
  });
  Future<User> getCurrentUser();
  Future<void> logout();
}
