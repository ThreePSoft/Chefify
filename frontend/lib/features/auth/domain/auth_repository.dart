import 'package:frontend/features/auth/domain/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession?> restoreSession();

  Future<AuthSession> signIn({required String email, required String password});

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthSession> updateProfile({
    required AuthSession session,
    required String name,
  });

  Future<void> signOut();
}
