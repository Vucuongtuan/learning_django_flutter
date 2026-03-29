import 'package:app_flutter/models/auth_token.dart';
import 'package:app_flutter/services/api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<AuthToken> login({
    required String username,
    required String password,
  }) async {
    final data = await _api.post('/token/', body: {
      'username': username,
      'password': password,
    });

    final token = AuthToken.fromJson(data as Map<String, dynamic>);
    await _api.saveTokens(
      accessToken: token.access,
      refreshToken: token.refresh,
    );
    return token;
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await _api.post('/register/', body: {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<void> logout() async {
    await _api.clearTokens();
  }

  Future<bool> tryAutoLogin() async {
    await _api.loadTokens();
    return _api.isAuthenticated;
  }
}
