import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../../../core/network/token_storage.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  @override
  Future<AuthToken> login(String kullaniciAdi, String parola) async {
    // 🔓 BYPASS: Test credentials for development without backend
    if (kullaniciAdi == 'admin' && parola == 'admin123') {
      // Mock token for bypass login
      final mockToken = AuthToken(
        token: 'test-token-bypass-${DateTime.now().millisecondsSinceEpoch}',
        expiration: DateTime.now().add(const Duration(days: 30)),
      );
      await _tokenStorage.saveToken(mockToken.token);
      return mockToken;
    }

    // Real backend login
    final tokenDto = await _remoteDataSource.login(kullaniciAdi, parola);
    // Store token
    await _tokenStorage.saveToken(tokenDto.token);
    return tokenDto;
  }

  @override
  Future<User> register({
    required String kullaniciAdi,
    required String parola,
    required String hesapSeviyesi,
    int? personelId,
  }) async {
    return await _remoteDataSource.register(
      kullaniciAdi: kullaniciAdi,
      parola: parola,
      hesapSeviyesi: hesapSeviyesi,
      personelId: personelId,
    );
  }

  @override
  Future<User> getCurrentUser() async {
    // 🔓 BYPASS: Return mock user for test token
    final token = await _tokenStorage.getToken();
    if (token != null && token.startsWith('test-token-bypass')) {
      return User(
        id: 1,
        kullaniciAdi: 'admin',
        hesapSeviyesi: 'admin',
        personelId: null,
        personelAdi: 'Admin User',
        kayitTarihi: DateTime.now(),
      );
    }

    // Real backend call
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }
}
