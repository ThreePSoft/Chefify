import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:frontend/features/recipes/presentation/controllers/recipe_collection_controller.dart';
import 'package:frontend/shared/models/home_models.dart';

void main() {
  test('publishes loading and success states', () async {
    final repository = _ControlledRecipeRepository();
    final controller = RecipeCollectionController(repository: repository);
    final statuses = <RecipeCollectionStatus>[];
    controller.addListener(() => statuses.add(controller.status));

    final load = controller.load();
    repository.requests.single.complete(const [_recipe]);
    await load;

    expect(statuses, [
      RecipeCollectionStatus.loading,
      RecipeCollectionStatus.success,
    ]);
    expect(controller.recipes, const [_recipe]);
    expect(controller.error, isNull);
  });

  test('publishes a failure without replacing it with demo data', () async {
    final repository = _ControlledRecipeRepository();
    final controller = RecipeCollectionController(repository: repository);
    final failure = RecipeRepositoryFailure(
      kind: RecipeRepositoryFailureKind.server,
      message: 'Unavailable',
      statusCode: 503,
    );

    final load = controller.load();
    repository.requests.single.completeError(failure);
    await load;

    expect(controller.status, RecipeCollectionStatus.failure);
    expect(controller.recipes, isEmpty);
    expect(controller.error, same(failure));
  });

  test('ignores an older response after a retry', () async {
    final repository = _ControlledRecipeRepository();
    final controller = RecipeCollectionController(repository: repository);

    final firstLoad = controller.load();
    final secondLoad = controller.load();
    repository.requests[1].complete(const [_recipe]);
    await secondLoad;
    repository.requests[0].complete(const []);
    await firstLoad;

    expect(controller.status, RecipeCollectionStatus.success);
    expect(controller.recipes, const [_recipe]);
  });
}

const _recipe = RecipeModel(
  id: 'recipe-1',
  title: 'Soup',
  categoryId: 'soups',
  categoryName: 'Soups',
  author: 'Chef',
  minutes: 20,
  rating: 4.8,
  accentColor: Color(0xFF000000),
);

final class _ControlledRecipeRepository implements RecipeRepository {
  final List<Completer<List<RecipeModel>>> requests = [];

  @override
  Future<List<RecipeModel>> fetchRecipes() {
    final request = Completer<List<RecipeModel>>();
    requests.add(request);
    return request.future;
  }

  @override
  Future<List<RecipeModel>> fetchPopularRecipes({int take = 4}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateRecipeLike({
    required String recipeId,
    required bool isLiked,
  }) {
    throw UnimplementedError();
  }
}
