import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/mock_auth_repository.dart';

void main() {
  test('supports a complete standalone mock session', () async {
    final repository = MockAuthRepository();

    expect(await repository.restoreSession(), isNull);

    final session = await repository.signIn(
      email: 'qa.tester@example.com',
      password: 'password',
    );

    expect(session.user.name, 'Qa Tester');
    expect(session.user.role, 'Tester');
    expect(await repository.restoreSession(), same(session));

    await repository.signOut();
    expect(await repository.restoreSession(), isNull);
  });
}
