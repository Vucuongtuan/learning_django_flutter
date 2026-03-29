import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String _accessTokenKey = 'jwt_access_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _accessToken;
  String? _refreshToken;

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  bool get isAuthenticated => _accessToken != null;
  String? get accessToken => _accessToken;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final retryResponse = await http.get(uri, headers: _headers);
        if (retryResponse.statusCode == 200) {
          return jsonDecode(utf8.decode(retryResponse.bodyBytes));
        }
        throw ApiException('GET $endpoint failed', retryResponse.statusCode);
      }
      throw ApiException('Token expired', 401);
    }

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw ApiException('GET $endpoint failed', response.statusCode);
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final retryResponse = await http.post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null);
        if (retryResponse.statusCode == 200 || retryResponse.statusCode == 201) {
          return jsonDecode(utf8.decode(retryResponse.bodyBytes));
        }
        throw ApiException('POST $endpoint failed', retryResponse.statusCode, body: utf8.decode(retryResponse.bodyBytes));
      }
      throw ApiException('Token expired', 401);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw ApiException('POST $endpoint failed', response.statusCode, body: utf8.decode(response.bodyBytes));
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final retryResponse = await http.put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null);
        if (retryResponse.statusCode == 200) {
          return jsonDecode(utf8.decode(retryResponse.bodyBytes));
        }
        throw ApiException('PUT $endpoint failed', retryResponse.statusCode);
      }
      throw ApiException('Token expired', 401);
    }

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw ApiException('PUT $endpoint failed', response.statusCode);
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.patch(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final retryResponse = await http.patch(uri, headers: _headers, body: body != null ? jsonEncode(body) : null);
        if (retryResponse.statusCode == 200) {
          return jsonDecode(utf8.decode(retryResponse.bodyBytes));
        }
        throw ApiException('PATCH $endpoint failed', retryResponse.statusCode);
      }
      throw ApiException('Token expired', 401);
    }

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw ApiException('PATCH $endpoint failed', response.statusCode);
  }

  Future<void> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(uri, headers: _headers);

    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final retryResponse = await http.delete(uri, headers: _headers);
        if (retryResponse.statusCode != 204 && retryResponse.statusCode != 200) {
          throw ApiException('DELETE $endpoint failed', retryResponse.statusCode);
        }
        return;
      }
      throw ApiException('Token expired', 401);
    }

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException('DELETE $endpoint failed', response.statusCode);
    }
  }

  Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final uri = Uri.parse('$baseUrl/token/refresh/');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        await saveTokens(
          accessToken: data['access'] as String,
          refreshToken: _refreshToken!,
        );
        return true;
      }
    } catch (_) {}

    await clearTokens();
    return false;
  }

  List<T> parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    final List<dynamic> results;
    if (data is Map<String, dynamic> && data.containsKey('results')) {
      results = data['results'] as List<dynamic>;
    } else if (data is List) {
      results = data;
    } else {
      results = [];
    }
    return results
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? body;

  ApiException(this.message, this.statusCode, {this.body});

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isBadRequest => statusCode == 400;
  bool get isServerError => statusCode == 500;

  @override
  String toString() => 'ApiException($statusCode): $message${body != null ? '\n$body' : ''}';
}
