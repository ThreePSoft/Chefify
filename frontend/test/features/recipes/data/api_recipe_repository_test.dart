import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/recipes/data/repositories/api_recipe_repository.dart';
import 'package:frontend/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiRecipeRepository', () {
    test('maps a successful recipes response', () async {
      final repository = ApiRecipeRepository(
        client: MockClient(
          (_) async =>
              http.Response('[{"id":"recipe-1","title":"Tomato soup"}]', 200),
        ),
      );

      final recipes = await repository.fetchRecipes();

      expect(recipes, hasLength(1));
      expect(recipes.single.id, 'recipe-1');
      expect(recipes.single.title, 'Tomato soup');
    });

    test('keeps an empty API collection empty', () async {
      final repository = ApiRecipeRepository(
        client: MockClient((_) async => http.Response('[]', 200)),
      );

      expect(await repository.fetchRecipes(), isEmpty);
    });

    test('reports a non-success response instead of returning mock data', () {
      final repository = ApiRecipeRepository(
        client: MockClient((_) async => http.Response('Unavailable', 503)),
      );

      expect(
        repository.fetchRecipes(),
        throwsA(
          isA<RecipeRepositoryFailure>()
              .having(
                (failure) => failure.kind,
                'kind',
                RecipeRepositoryFailureKind.server,
              )
              .having((failure) => failure.statusCode, 'statusCode', 503),
        ),
      );
    });

    test('reports malformed JSON as an invalid response', () {
      final repository = ApiRecipeRepository(
        client: MockClient((_) async => http.Response('{not-json}', 200)),
      );

      expect(
        repository.fetchRecipes(),
        throwsA(
          isA<RecipeRepositoryFailure>().having(
            (failure) => failure.kind,
            'kind',
            RecipeRepositoryFailureKind.invalidResponse,
          ),
        ),
      );
    });

    test('reports a timeout', () {
      final repository = ApiRecipeRepository(
        timeout: const Duration(milliseconds: 1),
        client: MockClient((_) => Completer<http.Response>().future),
      );

      expect(
        repository.fetchRecipes(),
        throwsA(
          isA<RecipeRepositoryFailure>().having(
            (failure) => failure.kind,
            'kind',
            RecipeRepositoryFailureKind.timeout,
          ),
        ),
      );
    });

    test('reports a failed like update', () {
      final repository = ApiRecipeRepository(
        client: MockClient((_) async => http.Response('', 404)),
      );

      expect(
        repository.updateRecipeLike(recipeId: 'missing', isLiked: true),
        throwsA(
          isA<RecipeRepositoryFailure>().having(
            (failure) => failure.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    });
  });
}
