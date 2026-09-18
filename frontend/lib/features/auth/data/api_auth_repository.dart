import 'dart:async';
import 'dart:convert';

import 'package:frontend/features/auth/data/auth_session_storage.dart';
import 'package:frontend/features/auth/domain/auth_repository.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:http/http.dart' as http;

final class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    this.baseUrl = const String.fromEnvironment(
      'CHEFIFY_API_BASE_URL',
      defaultValue: 'http://localhost:8080/api',
    ),
    this.timeout = const Duration(seconds: 8),
    http.Client? client,
    AuthSessionStorage? storage,
  }) : _client = client ?? http.Client(),
       _storage = storage ?? SharedPreferencesAuthSessionStorage();

  final String baseUrl;
  final Duration timeout;
  final http.Client _client;
  final AuthSessionStorage _storage;

  @override
  Future<AuthSession?> restoreSession() => _storage.read();

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _post('Auth/login', {
      'email': email.trim(),
      'password': password,
    });
    if (response.statusCode == 401 || response.statusCode == 404) {
      throw const AuthFailure(AuthFailureKind.invalidCredentials);
    }
    _ensureSuccess(response);

    final session = _sessionFromResponse(response);
    await _storage.write(session);
    return session;
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _post('Auth/register', {
      'username': name.trim(),
      'email': email.trim(),
      'password': password,
    });
    if (response.statusCode == 400 &&
        response.body.toLowerCase().contains('email')) {
      throw const AuthFailure(AuthFailureKind.emailAlreadyExists);
    }
    _ensureSuccess(response);
    return signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() => _storage.clear();

  Future<http.Response> _post(String path, Map<String, String> body) async {
    try {
      return await _client
          .post(
            _uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException catch (error) {
      throw AuthFailure(AuthFailureKind.timeout, cause: error);
    } on http.ClientException catch (error) {
      throw AuthFailure(AuthFailureKind.network, cause: error);
    }
  }

  AuthSession _sessionFromResponse(http.Response response) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken = json['accessToken'] as String;
      final refreshToken = json['refreshToken'] as String;
      final claims = _decodeJwtPayload(accessToken);
      return AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: AuthUser(
          id: _claim(claims, const [
            'nameid',
            'sub',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
          ]),
          name: _claim(claims, const [
            'unique_name',
            'name',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name',
          ]),
          email: _claim(claims, const [
            'email',
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress',
          ]),
          role: _claim(claims, const [
            'role',
            'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
          ]),
        ),
      );
    } on Object catch (error) {
      throw AuthFailure(AuthFailureKind.invalidResponse, cause: error);
    }
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('JWT must contain three parts.');
    }
    return jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        )
        as Map<String, dynamic>;
  }

  String _claim(Map<String, dynamic> claims, List<String> keys) {
    for (final key in keys) {
      final value = claims[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
      if (value != null) {
        return value.toString();
      }
    }
    throw const FormatException('Required identity claim is missing.');
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw AuthFailure(AuthFailureKind.server, statusCode: response.statusCode);
  }

  Uri _uri(String path) {
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(normalizedBaseUrl).resolve(path);
  }
}
