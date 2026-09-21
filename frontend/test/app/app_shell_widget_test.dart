// ignore_for_file: unused_import

import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/features/categories/presentation/pages/categories_page.dart';
import 'package:frontend/features/auth/domain/auth_repository.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:frontend/features/home/presentation/widgets/category_card.dart';
import 'package:frontend/features/home/presentation/widgets/hero_section.dart';
import 'package:frontend/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/features/recipes/presentation/pages/recipe_create_page.dart';
import 'package:frontend/features/recipes/presentation/pages/recipe_details_page.dart';
import 'package:frontend/features/recipes/presentation/pages/recipes_page.dart';
import 'package:frontend/shared/bookmarks/bookmark_button.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

import '../support/widget_test_harness.dart';

void main() {
  testWidgets('renders chefify home sections', (tester) async {
    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chefify'), findsWidgets);
    expect(find.text('Browse by category'), findsOneWidget);
    expect(find.text('Recipes everyone is saving'), findsOneWidget);
    expect(find.text('Weekly recipes in your inbox'), findsOneWidget);
  });

  testWidgets('main app pages fit common viewport widths', (tester) async {
    final sizes = [
      const Size(320, 1200),
      const Size(390, 1200),
      const Size(768, 1200),
      const Size(1024, 1200),
      const Size(1440, 1200),
    ];

    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in sizes) {
      tester.view.physicalSize = size;

      await tester.pumpWidget(
        const PageTestApp(
          child: HomePage(recipeRepository: MockRecipeRepository()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Home overflow at ${size.width}px',
      );

      await tester.pumpWidget(
        const PageTestApp(
          child: RecipesPage(recipeRepository: MockRecipeRepository()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Recipes overflow at ${size.width}px',
      );

      await tester.pumpWidget(
        const PageTestApp(
          child: CategoriesPage(recipeRepository: MockRecipeRepository()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Categories overflow at ${size.width}px',
      );

      await tester.pumpWidget(
        const PageTestApp(
          child: RecipeDetailsPage(
            recipeId: 'citrus-herb-chicken-quinoa',
            initialRecipe: featuredRecipe,
            recipeRepository: MockRecipeRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Recipe details overflow at ${size.width}px',
      );

      await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Recipe create overflow at ${size.width}px',
      );
    }
  });

  testWidgets('opens author profile from recipe card author chip', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Recipes').first);
    await tester.pumpAndSettle();

    final recipeCard = find.byKey(
      const ValueKey('recipes-card-roasted-tomato-pasta'),
    );
    await tester.scrollUntilVisible(
      recipeCard,
      360,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 180));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('recipe-author-chip-roasted-tomato-pasta')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('author-profile-page-chef-aria')),
      findsOneWidget,
    );
    expect(find.text('Chef Aria'), findsWidgets);
  });

  testWidgets('opens categories page from category see all action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -620),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all').first);
    await tester.pumpAndSettle();

    expect(find.text('Explore every category'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('categories-search-field')),
      findsOneWidget,
    );
  });

  testWidgets('opens the signed-in profile from the own author card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bookmarks = BookmarkStore.memory(
      const BookmarkSnapshot(recipeIds: {'citrus-herb-chicken-quinoa'}),
    );
    addTearDown(bookmarks.dispose);
    await tester.pumpWidget(
      ChefifyApp(
        authRepository: const _RestoredAuthRepository(),
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Recipes').first);
    await tester.pumpAndSettle();

    final recipeCard = find.byKey(
      const ValueKey('recipes-card-roasted-tomato-pasta'),
    );
    await tester.scrollUntilVisible(
      recipeCard,
      360,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 180));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('recipe-author-chip-roasted-tomato-pasta')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-header')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile-recipe-roasted-tomato-pasta')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-recipe-citrus-herb-chicken-quinoa')),
      findsNothing,
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('profile-tabs')),
        matching: find.text('Favorite recipes'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('profile-recipe-citrus-herb-chicken-quinoa')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('author-profile-page-chef-aria')),
      findsNothing,
    );
  });
}

class _RestoredAuthRepository implements AuthRepository {
  const _RestoredAuthRepository();

  static const session = AuthSession(
    accessToken: 'access',
    refreshToken: 'refresh',
    user: AuthUser(
      id: '7',
      name: 'Chef Aria',
      email: 'aria@chefify.test',
      role: 'User',
    ),
  );

  @override
  Future<AuthSession?> restoreSession() async => session;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async => session;

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async => session;

  @override
  Future<AuthSession> updateProfile({
    required AuthSession session,
    required String name,
  }) async => session.copyWith(user: session.user.copyWith(name: name));

  @override
  Future<void> signOut() async {}
}
