import 'package:frontend/shared/models/home_models.dart';

abstract interface class RecipeRepository {
  Future<List<RecipeModel>> fetchRecipes();

  Future<List<RecipeModel>> fetchPopularRecipes({int take = 4});

  Future<void> updateRecipeLike({
    required String recipeId,
    required bool isLiked,
  });
}

enum RecipeRepositoryFailureKind { network, timeout, server, invalidResponse }

final class RecipeRepositoryFailure implements Exception {
  const RecipeRepositoryFailure({
    required this.kind,
    required this.message,
    this.statusCode,
    this.cause,
  });

  final RecipeRepositoryFailureKind kind;
  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => 'RecipeRepositoryFailure($kind): $message';
}
