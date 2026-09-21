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

import '../../../support/widget_test_harness.dart';

void main() {
  testWidgets('autocompletes recipe title suggestions', (tester) async {
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

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'miso',
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey('recipe-search-suggestion-recipe-miso-glazed-salmon'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipes-card-miso-glazed-salmon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsNothing,
    );
  });

  testWidgets('opens recipe details from recipe card', (tester) async {
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

    await tester.tap(recipeCard);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-details-page-roasted-tomato-pasta')),
      findsOneWidget,
    );
    expect(find.text('Cook profile'), findsOneWidget);
  });

  testWidgets('creates recipe reviews and paginates review list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const PageTestApp(
        child: RecipeDetailsPage(
          recipeId: 'citrus-herb-chicken-quinoa',
          initialRecipe: featuredRecipe,
          recipeRepository: MockRecipeRepository(),
          usesMockData: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('recipe-review-comment-field')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('recipe-review-comment-field')),
      'Loved the balance and timing.',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('recipe-review-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Loved the balance and timing.'), findsOneWidget);
    expect(find.textContaining('Showing 1-20'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byTooltip('Next review page'),
      800,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next review page'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Showing 21-40'), findsOneWidget);
  });
}
