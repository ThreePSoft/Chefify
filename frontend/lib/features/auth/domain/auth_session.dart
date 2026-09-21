import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String role;

  AuthUser copyWith({String? name}) {
    return AuthUser(id: id, name: name ?? this.name, email: email, role: role);
  }

  String get initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2);
    final value = words.map((word) => word[0].toUpperCase()).join();
    return value.isEmpty ? '?' : value;
  }
}

@immutable
class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final AuthUser user;
  final String accessToken;
  final String refreshToken;

  AuthSession copyWith({AuthUser? user}) {
    return AuthSession(
      user: user ?? this.user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

enum AuthFailureKind {
  invalidCredentials,
  emailAlreadyExists,
  network,
  timeout,
  invalidResponse,
  server,
}

class AuthFailure implements Exception {
  const AuthFailure(this.kind, {this.statusCode, this.cause});

  final AuthFailureKind kind;
  final int? statusCode;
  final Object? cause;
}
