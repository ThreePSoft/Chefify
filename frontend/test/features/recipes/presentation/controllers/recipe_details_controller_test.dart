import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:frontend/features/recipes/presentation/controllers/recipe_details_controller.dart';
import 'package:frontend/shared/models/home_models.dart';

void main() {
  test('loads a recipe by a normalized route slug', () async {
    final controller = RecipeDetailsController(
      repository: _RecipeRepository(recipes: const [_recipe]),
      recipeId: 'tomato-soup',
    );

    await controller.load();

    expect(controller.status, RecipeDetailsStatus.ready);
    expect(controller.recipe, same(_recipe));
  });

  test('distinguishes not found from repository failure', () async {
    final missingController = RecipeDetailsController(
      repository: _RecipeRepository(recipes: const []),
      recipeId: 'missing',
    );
    await missingController.load();

    final failingController = RecipeDetailsController(
      repository: _RecipeRepository(loadError: StateError('offline')),
      recipeId: 'missing',
    );
    await failingController.load();

    expect(missingController.status, RecipeDetailsStatus.notFound);
    expect(failingController.status, RecipeDetailsStatus.failure);
    expect(failingController.error, isA<StateError>());
  });

  test('rolls back an optimistic like when persistence fails', () async {
    final controller = RecipeDetailsController(
      repository: _RecipeRepository(
        recipes: const [_recipe],
        likeError: StateError('unavailable'),
      ),
      recipeId: _recipe.id,
      initialRecipe: _recipe,
    );

    final persisted = await controller.toggleLike();

    expect(persisted, isFalse);
    expect(controller.isLiked, isFalse);
    expect(controller.likesCount, _recipe.likesCount);
  });

  test('prepends a submitted review', () {
    final controller = RecipeDetailsController(
      repository: _RecipeRepository(recipes: const [_recipe]),
      recipeId: _recipe.id,
      initialRecipe: _recipe,
      usesMockData: true,
    );

    controller.addReview(rating: 5, comment: 'Excellent.');

    expect(controller.reviews.first.author, 'You');
    expect(controller.reviews.first.rating, 5);
    expect(controller.reviews.first.comment, 'Excellent.');
  });

  test('does not invent reviews or likes in API mode', () {
    const recipeWithoutMetrics = RecipeModel(
      id: 'new-recipe',
      title: 'New Recipe',
      categoryId: 'soups',
      categoryName: 'Soups',
      author: 'Ana Cook',
      minutes: 15,
      rating: 4.8,
      accentColor: Color(0xFFAA0000),
    );
    final controller = RecipeDetailsController(
      repository: _RecipeRepository(recipes: const [recipeWithoutMetrics]),
      recipeId: recipeWithoutMetrics.id,
      initialRecipe: recipeWithoutMetrics,
    );

    controller.addReview(rating: 5, comment: 'Local-only review.');

    expect(controller.likesCount, 0);
    expect(controller.reviews, isEmpty);
  });
}

const _recipe = RecipeModel(
  id: 'tomato-soup',
  title: 'Tomato Soup',
  categoryId: 'soups',
  categoryName: 'Soups',
  author: 'Ana Cook',
  minutes: 15,
  rating: 4.8,
  accentColor: Color(0xFFAA0000),
  likesCount: 42,
);

final class _RecipeRepository implements RecipeRepository {
  _RecipeRepository({this.recipes = const [], this.loadError, this.likeError});

  final List<RecipeModel> recipes;
  final Object? loadError;
  final Object? likeError;

  @override
  Future<List<RecipeModel>> fetchRecipes() async {
    if (loadError case final error?) {
      throw error;
    }
    return recipes;
  }

  @override
  Future<List<RecipeModel>> fetchPopularRecipes({int take = 4}) async {
    return recipes.take(take).toList(growable: false);
  }

  @override
  Future<void> updateRecipeLike({
    required String recipeId,
    required bool isLiked,
  }) async {
    if (likeError case final error?) {
      throw error;
    }
  }
}
