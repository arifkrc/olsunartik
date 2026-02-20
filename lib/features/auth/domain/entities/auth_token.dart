class AuthToken {
  final String token;
  final DateTime expiration;

  AuthToken({required this.token, required this.expiration});

  bool get isExpired => DateTime.now().isAfter(expiration);
}
