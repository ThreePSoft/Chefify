import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/app_config.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/features/auth/domain/auth_repository.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';

void main() {
  testWidgets('centers auth cards and keeps the larger brand on the left', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        config: const AppConfig(dataMode: AppDataMode.mock),
        bookmarkStore: bookmarks,
        settingsStorage: MemoryAppSettingsStorage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    _expectCenteredAuthLayout(tester);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    _expectCenteredAuthLayout(tester);

    tester.view.physicalSize = const Size(390, 700);
    await tester.pumpAndSettle();
    final compactBrand = tester.getRect(
      find.byKey(const ValueKey('auth-brand')),
    );
    final compactCard = tester.getRect(find.byKey(const ValueKey('auth-card')));
    expect(compactBrand.bottom, lessThan(compactCard.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'login opens the authenticated profile and sign out returns home',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bookmarks = BookmarkStore.memory();
      addTearDown(bookmarks.dispose);
      final repository = _FakeAuthRepository();

      await tester.pumpWidget(
        ChefifyApp(
          authRepository: repository,
          bookmarkStore: bookmarks,
          recipeRepository: const MockRecipeRepository(),
          settingsStorage: MemoryAppSettingsStorage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('auth-email-field')),
        'cook@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-password-field')),
        'password',
      );
      await tester.tap(find.byKey(const ValueKey('auth-login-submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('profile-user-name')), findsOneWidget);
      expect(find.text('Chef Test'), findsWidgets);
      expect(repository.signInCount, 1);
      expect(
        find.byKey(const ValueKey('header-profile-action')),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('header-profile-mark'))),
        const Size.square(38),
      );

      await tester.tap(find.byKey(const ValueKey('profile-sign-out')));
      await tester.pumpAndSettle();
      expect(find.text('Log in'), findsOneWidget);
      expect(repository.didSignOut, isTrue);
    },
  );

  testWidgets('registration validates fields and creates a profile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(
      ChefifyApp(
        authRepository: repository,
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
        settingsStorage: MemoryAppSettingsStorage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('auth-name-field')),
      'Chef Test',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-email-field')),
      'cook@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-password-field')),
      'password',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-confirm-password-field')),
      'password',
    );
    await tester.tap(find.byKey(const ValueKey('auth-register-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-user-name')), findsOneWidget);
    expect(repository.registerCount, 1);
  });
}

void _expectCenteredAuthLayout(WidgetTester tester) {
  final card = tester.getRect(find.byKey(const ValueKey('auth-card')));
  final brand = tester.getRect(find.byKey(const ValueKey('auth-brand')));
  final mark = tester.getSize(find.byKey(const ValueKey('auth-brand-mark')));
  final viewportCenter = tester.view.physicalSize / 2;

  expect(card.center.dx, closeTo(viewportCenter.width, 1));
  expect(card.center.dy, closeTo(viewportCenter.height, 1));
  expect(brand.left, lessThan(card.left));
  expect(mark, const Size.square(46));
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
  int signInCount = 0;
  int registerCount = 0;
  bool didSignOut = false;

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    signInCount++;
    return _session;
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    registerCount++;
    return _session;
  }

  @override
  Future<void> signOut() async {
    didSignOut = true;
  }
}
