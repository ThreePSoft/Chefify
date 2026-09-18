import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/domain/auth_repository.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:frontend/features/auth/presentation/auth_controller.dart';

void main() {
  test('restores, signs in, and clears an authenticated session', () async {
    final repository = _FakeAuthRepository();
    final controller = AuthController(repository: repository);

    await controller.restore();
    expect(controller.isRestored, isTrue);
    expect(controller.user, isNull);

    expect(
      await controller.signIn(email: 'cook@example.com', password: 'password'),
      isTrue,
    );
    expect(controller.user?.name, 'Chef Test');

    await controller.signOut();
    expect(controller.user, isNull);
    expect(repository.didSignOut, isTrue);
  });

  test('exposes typed authentication failures to the UI', () async {
    final repository = _FakeAuthRepository(
      signInFailure: const AuthFailure(AuthFailureKind.invalidCredentials),
    );
    final controller = AuthController(repository: repository);

    expect(
      await controller.signIn(email: 'cook@example.com', password: 'wrongpass'),
      isFalse,
    );
    expect(controller.failure, AuthFailureKind.invalidCredentials);
    expect(controller.isBusy, isFalse);
  });
}

const _session = AuthSession(
  accessToken: 'access',
  refreshToken: 'refresh',
  user: AuthUser(
    id: '42',
    name: 'Chef Test',
    email: 'cook@example.com',
    role: 'User',
  ),
);

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.signInFailure});

  final AuthFailure? signInFailure;
  bool didSignOut = false;

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    if (signInFailure case final failure?) throw failure;
    return _session;
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async => _session;

  @override
  Future<void> signOut() async {
    didSignOut = true;
  }
}
