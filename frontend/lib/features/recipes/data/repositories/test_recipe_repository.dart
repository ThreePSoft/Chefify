import 'package:frontend/features/recipes/data/repositories/api_recipe_repository.dart';
import 'package:frontend/features/recipes/data/repositories/mock_recipe_repository.dart';
import 'package:frontend/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:frontend/shared/models/home_models.dart';

/// Combines live API records with the demo catalog used by QA.
///
/// The live API is preferred, while the demo catalog keeps UI testing usable
/// when the backend is temporarily unavailable. Authentication remains API-only.
final class TestRecipeRepository implements RecipeRepository {
  TestRecipeRepository({
    RecipeRepository? apiRepository,
    RecipeRepository? mockRepository,
  }) : _apiRepository = apiRepository ?? const ApiRecipeRepository(),
       _mockRepository = mockRepository ?? const MockRecipeRepository();

  final RecipeRepository _apiRepository;
  final RecipeRepository _mockRepository;
  Set<String> _apiRecipeIds = const {};

  @override
  Future<List<RecipeModel>> fetchRecipes() async {
    final mockRecipes = await _mockRepository.fetchRecipes();
    try {
      final apiRecipes = await _apiRepository.fetchRecipes();
      _apiRecipeIds = apiRecipes.map((recipe) => recipe.id).toSet();

      return [
        ...apiRecipes,
        ...mockRecipes.where((recipe) => !_apiRecipeIds.contains(recipe.id)),
      ];
    } on RecipeRepositoryFailure {
      _apiRecipeIds = const {};
      return mockRecipes;
    }
  }

  @override
  Future<List<RecipeModel>> fetchPopularRecipes({int take = 4}) async {
    if (take <= 0) {
      return const [];
    }
    final recipes = [...await fetchRecipes()]
      ..sort((left, right) {
        final rating = right.rating.compareTo(left.rating);
        return rating != 0 ? rating : left.title.compareTo(right.title);
      });
    return recipes.take(take).toList(growable: false);
  }

  @override
  Future<void> updateRecipeLike({
    required String recipeId,
    required bool isLiked,
  }) {
    final repository = _apiRecipeIds.contains(recipeId)
        ? _apiRepository
        : _mockRepository;
    return repository.updateRecipeLike(recipeId: recipeId, isLiked: isLiked);
  }
}
