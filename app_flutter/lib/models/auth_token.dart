class AuthToken {
  final String access;
  final String refresh;

  const AuthToken({
    required this.access,
    required this.refresh,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }
}
