import '../../domain/entities/auth_token.dart';

class AuthTokenDto extends AuthToken {
  final int? userId;
  final String? username;
  final int? hesapSeviyesi;

  AuthTokenDto({
    required super.token,
    required super.expiration,
    this.userId,
    this.username,
    this.hesapSeviyesi,
  });

  factory AuthTokenDto.fromJson(Map<String, dynamic> json) {
    return AuthTokenDto(
      token: json['token'] as String,
      expiration: DateTime.parse(json['expiration'] as String),
      userId: json['userId'] as int?,
      username: json['username'] as String?,
      hesapSeviyesi: json['hesapSeviyesi'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiration': expiration.toIso8601String(),
      'userId': userId,
      'username': username,
      'hesapSeviyesi': hesapSeviyesi,
    };
  }
}
