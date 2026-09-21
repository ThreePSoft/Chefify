import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:frontend/shared/models/home_models.dart';

enum RecipeDetailsStatus { initial, loading, ready, notFound, failure }

@immutable
class RecipeReview {
  const RecipeReview({
    required this.id,
    required this.author,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String author;
  final int rating;
  final String comment;
  final DateTime createdAt;
}

final class RecipeDetailsController extends ChangeNotifier {
  RecipeDetailsController({
    required RecipeRepository repository,
    required String recipeId,
    RecipeModel? initialRecipe,
    this.usesMockData = false,
  }) : _repository = repository,
       _recipeId = recipeId,
       _recipe = initialRecipe,
       _status = initialRecipe == null
           ? RecipeDetailsStatus.initial
           : RecipeDetailsStatus.ready;

  final bool usesMockData;

  RecipeRepository _repository;
  String _recipeId;
  RecipeModel? _recipe;
  RecipeDetailsStatus _status;
  Object? _error;
  bool _isLiked = false;
  int _requestVersion = 0;
  int _likeMutationVersion = 0;
  bool _isDisposed = false;
  final Map<String, List<RecipeReview>> _reviewsByRecipeId = {};

  RecipeModel? get recipe => _recipe;
  RecipeDetailsStatus get status => _status;
  Object? get error => _error;
  bool get isLoading => _status == RecipeDetailsStatus.loading;
  bool get hasError => _status == RecipeDetailsStatus.failure;
  bool get isLiked => _isLiked;

  int get likesCount {
    final currentRecipe = _recipe;
    if (currentRecipe == null) {
      return 0;
    }
    return _baseLikesCount(
          currentRecipe,
          usesMockData: usesMockData && currentRecipe.isDemo,
        ) +
        (_isLiked ? 1 : 0);
  }

  List<RecipeReview> get reviews {
    final currentRecipe = _recipe;
    if (currentRecipe == null) {
      return const [];
    }

    return List.unmodifiable(
      _reviewsByRecipeId.putIfAbsent(
        currentRecipe.id,
        () => usesMockData && currentRecipe.isDemo
            ? _seedReviewsFor(currentRecipe)
            : const [],
      ),
    );
  }

  void update({
    required RecipeRepository repository,
    required String recipeId,
    RecipeModel? initialRecipe,
  }) {
    _repository = repository;
    _recipeId = recipeId;
    _recipe = initialRecipe;
    _status = initialRecipe == null
        ? RecipeDetailsStatus.initial
        : RecipeDetailsStatus.ready;
    _error = null;
    _isLiked = false;
    _likeMutationVersion++;
    _requestVersion++;
    notifyListeners();

    if (initialRecipe == null) {
      unawaited(load());
    }
  }

  Future<void> load() async {
    final requestVersion = ++_requestVersion;
    _status = RecipeDetailsStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final recipes = await _repository.fetchRecipes();
      if (!_isCurrent(requestVersion)) {
        return;
      }

      _recipe = _findRecipe(recipes, _recipeId);
      _status = _recipe == null
          ? RecipeDetailsStatus.notFound
          : RecipeDetailsStatus.ready;
    } on Object catch (error) {
      if (!_isCurrent(requestVersion)) {
        return;
      }

      _error = error;
      _status = RecipeDetailsStatus.failure;
    }

    notifyListeners();
  }

  Future<bool> toggleLike() async {
    final currentRecipe = _recipe;
    if (currentRecipe == null) {
      return false;
    }

    final isLiked = !_isLiked;
    final mutationVersion = ++_likeMutationVersion;
    _isLiked = isLiked;
    notifyListeners();

    try {
      await _repository.updateRecipeLike(
        recipeId: currentRecipe.id,
        isLiked: isLiked,
      );
      return true;
    } on Object {
      if (_isDisposed || mutationVersion != _likeMutationVersion) {
        return true;
      }

      _isLiked = !isLiked;
      notifyListeners();
      return false;
    }
  }

  void addReview({required int rating, required String comment}) {
    if (!usesMockData || _recipe?.isDemo != true) {
      return;
    }
    final currentRecipe = _recipe;
    if (currentRecipe == null) {
      return;
    }

    final now = DateTime.now();
    final review = RecipeReview(
      id: '${currentRecipe.id}-review-user-${now.microsecondsSinceEpoch}',
      author: 'You',
      rating: rating,
      comment: comment,
      createdAt: now,
    );
    _reviewsByRecipeId[currentRecipe.id] = [review, ...reviews];
    notifyListeners();
  }

  bool _isCurrent(int requestVersion) {
    return !_isDisposed && requestVersion == _requestVersion;
  }

  RecipeModel? _findRecipe(List<RecipeModel> recipes, String recipeId) {
    final normalizedRouteId = CategoryCatalog.slug(recipeId);

    for (final recipe in recipes) {
      if (recipe.id == recipeId ||
          CategoryCatalog.slug(recipe.id) == normalizedRouteId ||
          CategoryCatalog.slug(recipe.title) == normalizedRouteId) {
        return recipe;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestVersion++;
    _likeMutationVersion++;
    super.dispose();
  }
}

int _baseLikesCount(RecipeModel recipe, {required bool usesMockData}) {
  if (recipe.likesCount > 0) {
    return recipe.likesCount;
  }

  if (!usesMockData) {
    return 0;
  }

  final popularityBoost = recipe.popularityScore > 0
      ? (recipe.popularityScore / 3).round()
      : 0;
  return (recipe.rating * 390).round() + 610 + popularityBoost;
}

List<RecipeReview> _seedReviewsFor(RecipeModel recipe) {
  const comments = [
    'Clear steps and the flavor landed exactly where I wanted it.',
    'Cooked this for dinner and it held up well for leftovers.',
    'The timing felt realistic and the result was easy to repeat.',
    'Nice balance of texture, seasoning, and prep effort.',
    'Good weeknight option. I would make it again with a little extra herbs.',
  ];
  const authors = [
    'Marta Cook',
    'Ivan Plate',
    'Sofia Green',
    'Nadia Table',
    'Oleh Spoon',
    'Kate Pantry',
  ];
  final count = 34 + (recipe.id.hashCode.abs() % 15);
  final baseDate = DateTime(2026, 6, 24, 18, 30);

  return List<RecipeReview>.generate(count, (index) {
    final rating = 5 - ((index + recipe.title.length) % 3);

    return RecipeReview(
      id: '${recipe.id}-review-$index',
      author: authors[index % authors.length],
      rating: rating,
      comment: comments[(index + recipe.categoryName.length) % comments.length],
      createdAt: baseDate.subtract(Duration(hours: index * 7)),
    );
  }, growable: false);
}
