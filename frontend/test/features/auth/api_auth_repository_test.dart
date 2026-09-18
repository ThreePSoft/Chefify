import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/api_auth_repository.dart';
import 'package:frontend/features/auth/data/auth_session_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('signs in, decodes identity claims, and persists the session', () async {
    final storage = MemoryAuthSessionStorage();
    final client = MockClient((request) async {
      expect(request.url.path, '/api/Auth/login');
      expect(jsonDecode(request.body), {
        'email': 'cook@example.com',
        'password': 'password',
      });
      return http.Response(
        jsonEncode({'accessToken': _token(), 'refreshToken': 'refresh-token'}),
        200,
      );
    });
    final repository = ApiAuthRepository(
      baseUrl: 'https://chefify.test/api',
      client: client,
      storage: storage,
    );

    final session = await repository.signIn(
      email: 'cook@example.com',
      password: 'password',
    );

    expect(session.user.id, '42');
    expect(session.user.name, 'Chef Test');
    expect(session.user.email, 'cook@example.com');
    expect(session.user.role, 'User');
    expect((await storage.read())?.refreshToken, 'refresh-token');
  });
}

String _token() {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'none'})}.${encode({'nameid': '42', 'unique_name': 'Chef Test', 'email': 'cook@example.com', 'role': 'User'})}.signature';
}
