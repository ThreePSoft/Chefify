import 'package:frontend/features/recipes/data/recipe_catalog.dart';
import 'package:frontend/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:frontend/shared/models/home_models.dart';

final class MockRecipeRepository implements RecipeRepository {
  const MockRecipeRepository();

  @override
  Future<List<RecipeModel>> fetchRecipes() async => RecipeCatalog.items
      .map((recipe) => recipe.copyWith(isDemo: true))
      .toList(growable: false);

  @override
  Future<List<RecipeModel>> fetchPopularRecipes({int take = 4}) async {
    if (take <= 0) {
      return const [];
    }
    return RecipeCatalog.popular(
      take: take,
    ).map((recipe) => recipe.copyWith(isDemo: true)).toList(growable: false);
  }

  @override
  Future<void> updateRecipeLike({
    required String recipeId,
    required bool isLiked,
  }) async {}
}
