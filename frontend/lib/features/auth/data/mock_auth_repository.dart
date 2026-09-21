import 'package:frontend/features/auth/domain/auth_repository.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';

final class MockAuthRepository implements AuthRepository {
  AuthSession? _session;

  @override
  Future<AuthSession?> restoreSession() async => _session;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    _session = AuthSession(
      user: AuthUser(
        id: 'mock-user',
        name: _displayNameFromEmail(normalizedEmail),
        email: normalizedEmail,
        role: 'Tester',
      ),
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
    );
    return _session!;
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _session = AuthSession(
      user: AuthUser(
        id: 'mock-user',
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: 'Tester',
      ),
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
    );
    return _session!;
  }

  @override
  Future<void> signOut() async {
    _session = null;
  }
}

String _displayNameFromEmail(String email) {
  final localPart = email.split('@').first.trim();
  if (localPart.isEmpty) {
    return 'Chefify Tester';
  }
  return localPart
      .split(RegExp(r'[._-]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
