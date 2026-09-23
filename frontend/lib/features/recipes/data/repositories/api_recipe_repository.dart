import 'dart:async';
import 'dart:convert';

import 'package:frontend/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:frontend/shared/models/home_models.dart';
import 'package:http/http.dart' as http;

final class ApiRecipeRepository implements RecipeRepository {
  const ApiRecipeRepository({
    this.baseUrl = const String.fromEnvironment(
      'CHEFIFY_API_BASE_URL',
      defaultValue: 'http://localhost:8080/api',
    ),
    this.timeout = const Duration(seconds: 3),
    this.client,
  });

  final String baseUrl;
  final Duration timeout;
  final http.Client? client;

  @override
  Future<List<RecipeModel>> fetchRecipes() => _fetchRecipes(path: 'Recipes');

  Future<List<RecipeModel>> fetchUserRecipes(String userId) {
    return _fetchRecipes(path: 'Users/${Uri.encodeComponent(userId)}/recipes');
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
  }) async {
    final response = await _request(
      () => _post(
        _uri('Recipes/${Uri.encodeComponent(recipeId)}/likes'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'liked': isLiked, 'delta': isLiked ? 1 : -1}),
      ),
    );

    _ensureSuccess(response, operation: 'update recipe like');
  }

  Future<List<RecipeModel>> _fetchRecipes({required String path}) async {
    final response = await _request(() => _get(_uri(path)));
    _ensureSuccess(response, operation: 'load recipes');

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const FormatException('Expected a JSON array.');
      }

      return decoded
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Recipe must be a JSON object.');
            }
            return RecipeModel.fromJson(item);
          })
          .toList(growable: false);
    } on RecipeRepositoryFailure {
      rethrow;
    } on Object catch (error) {
      throw RecipeRepositoryFailure(
        kind: RecipeRepositoryFailureKind.invalidResponse,
        message: 'The recipes response has an invalid format.',
        cause: error,
      );
    }
  }

  Future<http.Response> _request(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException catch (error) {
      throw RecipeRepositoryFailure(
        kind: RecipeRepositoryFailureKind.timeout,
        message: 'The recipes service did not respond in time.',
        cause: error,
      );
    } on http.ClientException catch (error) {
      throw RecipeRepositoryFailure(
        kind: RecipeRepositoryFailureKind.network,
        message: 'The recipes service could not be reached.',
        cause: error,
      );
    }
  }

  void _ensureSuccess(http.Response response, {required String operation}) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw RecipeRepositoryFailure(
      kind: RecipeRepositoryFailureKind.server,
      message: 'Could not $operation (HTTP ${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }

  Future<http.Response> _get(Uri uri) => client?.get(uri) ?? http.get(uri);

  Future<http.Response> _post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      client?.post(uri, headers: headers, body: body) ??
      http.post(uri, headers: headers, body: body);

  Uri _uri(String path, {Map<String, String>? queryParameters}) {
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(
      normalizedBaseUrl,
    ).resolve(path).replace(queryParameters: queryParameters);
  }
}
