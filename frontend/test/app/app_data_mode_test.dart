import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app_config.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/shared/models/home_models.dart';

import '../support/widget_test_harness.dart';

void main() {
  test('uses API data unless test mode is explicitly selected', () {
    expect(const AppConfig().dataMode, AppDataMode.api);
    expect(const AppConfig().includesMockData, isFalse);
    expect(
      const AppConfig(dataMode: AppDataMode.test).includesMockData,
      isTrue,
    );
  });

  testWidgets('API mode never renders homepage mock records', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const PageTestApp(
        child: HomePage(recipeRepository: _FailingRecipeRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Citrus Herb Chicken with Warm Quinoa'), findsNothing);
    expect(find.text('Sophie Lang'), findsNothing);
    expect(find.text('18K+'), findsNothing);
    expect(
      find.text('The recipes service is temporarily unavailable.'),
      findsOneWidget,
    );
  });

  testWidgets('test mode adds the complete demo homepage', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const PageTestApp(
        child: HomePage(
          recipeRepository: MockRecipeRepository(),
          usesMockData: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Citrus Herb Chicken with Warm Quinoa'), findsWidgets);
    expect(find.text('Sophie Lang'), findsOneWidget);
    expect(find.text('18K+'), findsOneWidget);
  });
}

final class _FailingRecipeRepository implements RecipeRepository {
  const _FailingRecipeRepository();

  @override
  Future<List<RecipeModel>> fetchRecipes() async {
    throw const RecipeRepositoryFailure(
      kind: RecipeRepositoryFailureKind.server,
      message: 'Unavailable',
    );
  }

  @override
  Future<List<RecipeModel>> fetchPopularRecipes({int take = 4}) =>
      fetchRecipes();

  @override
  Future<void> updateRecipeLike({
    required String recipeId,
    required bool isLiked,
  }) async {}
}
