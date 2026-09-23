// ignore_for_file: unused_import

import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/features/categories/presentation/pages/categories_page.dart';
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

import '../../support/widget_test_harness.dart';

void main() {
  testWidgets('opens recipes page from trending see all action', (
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
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all').last);
    await tester.pumpAndSettle();

    expect(find.text('Find your next cook'), findsOneWidget);
    expect(find.byKey(const ValueKey('recipes-search-field')), findsOneWidget);
  });

  testWidgets('toggles featured recipe bookmark icon', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        initialBookmarks: BookmarkSnapshot(
          recipeIds: <String>{'citrus-herb-chicken-quinoa'},
        ),
        child: HeroSection(
          title: 'Cook with confidence.',
          subtitle: 'Save recipes you want to cook later.',
          featuredRecipe: featuredRecipe,
        ),
      ),
    );

    expect(find.byTooltip(BookmarkButton.removeTooltip), findsOneWidget);
    expect(find.byTooltip(BookmarkButton.saveTooltip), findsNothing);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsNothing);

    await tester.tap(find.byTooltip(BookmarkButton.removeTooltip));
    await tester.pumpAndSettle();

    expect(find.byTooltip(BookmarkButton.removeTooltip), findsNothing);
    expect(find.byTooltip(BookmarkButton.saveTooltip), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_rounded), findsNothing);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
  });

  testWidgets('toggles category bookmark icon', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: SizedBox(
          width: 340,
          height: 248,
          child: CategoryCard(category: testCategory),
        ),
      ),
    );

    expect(find.byTooltip(BookmarkButton.saveTooltip), findsOneWidget);
    expect(find.byTooltip(BookmarkButton.removeTooltip), findsNothing);

    await tester.tap(find.byTooltip(BookmarkButton.saveTooltip));
    await tester.pumpAndSettle();

    expect(find.byTooltip(BookmarkButton.saveTooltip), findsNothing);
    expect(find.byTooltip(BookmarkButton.removeTooltip), findsOneWidget);
  });

  testWidgets('toggles trending recipe card bookmark icon', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: SizedBox(width: 320, child: RecipeCard(recipe: featuredRecipe)),
      ),
    );

    expect(find.byTooltip(BookmarkButton.saveTooltip), findsOneWidget);
    expect(find.byTooltip(BookmarkButton.removeTooltip), findsNothing);

    await tester.tap(find.byTooltip(BookmarkButton.saveTooltip));
    await tester.pumpAndSettle();

    expect(find.byTooltip(BookmarkButton.saveTooltip), findsNothing);
    expect(find.byTooltip(BookmarkButton.removeTooltip), findsOneWidget);
  });

  testWidgets('persists recipe bookmarks to storage', (tester) async {
    final storage = MemoryBookmarkStorage();
    final bookmarks = BookmarkStore(storage: storage);
    addTearDown(bookmarks.dispose);

    await bookmarks.load();

    expect(bookmarks.isRecipeSaved(featuredRecipe), isFalse);

    await bookmarks.toggleRecipe(featuredRecipe);

    expect(bookmarks.isRecipeSaved(featuredRecipe), isTrue);
    expect(storage.snapshot.recipeIds, contains('citrus-herb-chicken-quinoa'));

    await bookmarks.toggleRecipe(featuredRecipe);

    expect(bookmarks.isRecipeSaved(featuredRecipe), isFalse);
    expect(
      storage.snapshot.recipeIds,
      isNot(contains('citrus-herb-chicken-quinoa')),
    );
  });

  test('keeps bookmarks isolated between authenticated users', () async {
    final bookmarks = BookmarkStore(storage: MemoryBookmarkStorage());
    addTearDown(bookmarks.dispose);

    await bookmarks.useOwner('user-a');
    await bookmarks.setRecipeSaved(featuredRecipe, true);
    expect(bookmarks.isRecipeSaved(featuredRecipe), isTrue);

    await bookmarks.useOwner('user-b');
    expect(bookmarks.isRecipeSaved(featuredRecipe), isFalse);

    await bookmarks.useOwner('user-a');
    expect(bookmarks.isRecipeSaved(featuredRecipe), isTrue);
  });
}
