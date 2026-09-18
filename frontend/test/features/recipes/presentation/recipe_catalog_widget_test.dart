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
  testWidgets('opens recipes page and filters recipe catalog', (tester) async {
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

    expect(find.text('Find your next cook'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'salmon',
    );
    await tester.pumpAndSettle();

    expect(find.text('Miso Glazed Salmon'), findsWidgets);
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'high protein',
    );
    await tester.pumpAndSettle();

    expect(find.text('Miso Glazed Salmon'), findsWidgets);
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('recipes-category-chip-breakfast')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipes-card-lemon-ricotta-pancakes')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-miso-glazed-salmon')),
      findsNothing,
    );
  });

  testWidgets('opens recipe tag filters from recipe cards', (tester) async {
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

    final pastaTag = find.byKey(
      const ValueKey('recipe-card-tag-roasted-tomato-pasta-pasta'),
    );
    await tester.scrollUntilVisible(
      pastaTag,
      360,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 220));
    await tester.pumpAndSettle();

    await tester.tap(pastaTag);
    await tester.pumpAndSettle();

    expect(find.text('Find your next cook'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recipe-search-tag-token-pasta')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-miso-glazed-salmon')),
      findsNothing,
    );
  });

  testWidgets('selects tag suggestions as search tokens', (tester) async {
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
      'high',
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('recipe-search-suggestion-tag-high-protein')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-search-tag-token-high-protein')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-miso-glazed-salmon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsNothing,
    );
  });

  testWidgets('selects author suggestions as search tokens', (tester) async {
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
      'aria',
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('recipe-search-suggestion-author-chef-aria')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-search-author-token-chef-aria')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-miso-glazed-salmon')),
      findsNothing,
    );
  });

  testWidgets('clear search removes text tag and author tokens', (
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

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'high',
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('recipe-search-suggestion-tag-high-protein')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('recipes-search-field')),
      'aria',
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('recipe-search-suggestion-author-chef-aria')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-search-tag-token-high-protein')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipe-search-author-token-chef-aria')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-search-tag-token-high-protein')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('recipe-search-author-token-chef-aria')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('recipes-card-roasted-tomato-pasta')),
      findsOneWidget,
    );
  });
}
