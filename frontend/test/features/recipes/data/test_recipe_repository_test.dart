import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/recipes/data/repositories/test_recipe_repository.dart';
import 'package:frontend/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:frontend/shared/models/home_models.dart';

void main() {
  test(
    'combines API and mock recipes while preferring API duplicates',
    () async {
      final api = _RecordingRecipeRepository(recipes: const [_apiRecipe]);
      final mock = _RecordingRecipeRepository(
        recipes: const [_mockDuplicate, _mockOnlyRecipe],
      );
      final repository = TestRecipeRepository(
        apiRepository: api,
        mockRepository: mock,
      );

      final recipes = await repository.fetchRecipes();

      expect(recipes, hasLength(2));
      expect(recipes.first.title, 'Live API recipe');
      expect(recipes.last, same(_mockOnlyRecipe));
    },
  );

  test('keeps API failures visible instead of falling back to mocks', () {
    final repository = TestRecipeRepository(
      apiRepository: _RecordingRecipeRepository(
        error: const RecipeRepositoryFailure(
          kind: RecipeRepositoryFailureKind.server,
          message: 'Unavailable',
        ),
      ),
      mockRepository: _RecordingRecipeRepository(
        recipes: const [_mockOnlyRecipe],
      ),
    );

    expect(repository.fetchRecipes(), throwsA(isA<RecipeRepositoryFailure>()));
  });

  test('persists likes through API only for live records', () async {
    final api = _RecordingRecipeRepository(recipes: const [_apiRecipe]);
    final mock = _RecordingRecipeRepository(recipes: const [_mockOnlyRecipe]);
    final repository = TestRecipeRepository(
      apiRepository: api,
      mockRepository: mock,
    );
    await repository.fetchRecipes();

    await repository.updateRecipeLike(recipeId: _apiRecipe.id, isLiked: true);
    await repository.updateRecipeLike(
      recipeId: _mockOnlyRecipe.id,
      isLiked: true,
    );

    expect(api.likedRecipeIds, [_apiRecipe.id]);
    expect(mock.likedRecipeIds, [_mockOnlyRecipe.id]);
  });
}

const _apiRecipe = RecipeModel(
  id: 'shared-id',
  title: 'Live API recipe',
  categoryId: 'live',
  categoryName: 'Live',
  author: 'API user',
  minutes: 12,
  rating: 5,
  accentColor: Colors.orange,
);

const _mockDuplicate = RecipeModel(
  id: 'shared-id',
  title: 'Mock duplicate',
  categoryId: 'mock',
  categoryName: 'Mock',
  author: 'Demo user',
  minutes: 20,
  rating: 4,
  accentColor: Colors.green,
);

const _mockOnlyRecipe = RecipeModel(
  id: 'mock-only',
  title: 'Mock-only recipe',
  categoryId: 'mock',
  categoryName: 'Mock',
  author: 'Demo user',
  minutes: 20,
  rating: 4,
  accentColor: Colors.green,
);

final class _RecordingRecipeRepository implements RecipeRepository {
  _RecordingRecipeRepository({this.recipes = const [], this.error});

  final List<RecipeModel> recipes;
  final Object? error;
  final List<String> likedRecipeIds = [];

  @override
  Future<List<RecipeModel>> fetchRecipes() async {
    if (error case final loadError?) {
      throw loadError;
    }
    return recipes;
  }

  @override
  Future<List<RecipeModel>> fetchPopularRecipes({int take = 4}) async =>
      recipes.take(take).toList(growable: false);

  @override
  Future<void> updateRecipeLike({
    required String recipeId,
    required bool isLiked,
  }) async {
    likedRecipeIds.add(recipeId);
  }
}
