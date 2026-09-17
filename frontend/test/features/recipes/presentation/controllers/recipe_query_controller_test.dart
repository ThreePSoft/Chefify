import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/recipes/presentation/controllers/recipe_query_controller.dart';
import 'package:frontend/shared/models/home_models.dart';

void main() {
  final index = RecipeQueryIndex(_recipes);

  test('combines search, tags, time, and sort deterministically', () {
    final result = index.visibleRecipes(
      query: 'soup',
      selectedCategoryIds: const {},
      selectedTagIds: const {'vegan', 'quick'},
      selectedAuthorIds: const {},
      timeFilter: RecipeTimeFilter.under20,
      sort: RecipeSort.rating,
      savedOnly: false,
      isRecipeSaved: (_) => false,
    );

    expect(result.map((recipe) => recipe.id), ['tomato-soup']);
  });

  test('filters saved recipes through the supplied bookmark boundary', () {
    final result = index.visibleRecipes(
      query: '',
      selectedCategoryIds: const {},
      selectedTagIds: const {},
      selectedAuthorIds: const {},
      timeFilter: RecipeTimeFilter.any,
      sort: RecipeSort.title,
      savedOnly: true,
      isRecipeSaved: (recipe) => recipe.id == 'slow-stew',
    );

    expect(result.map((recipe) => recipe.id), ['slow-stew']);
  });

  test('builds typed tag, author, and recipe suggestions', () {
    final suggestions = index.suggestions(
      query: 'so',
      selectedTagIds: const {},
      selectedAuthorIds: const {},
    );

    expect(
      suggestions,
      contains(
        isA<RecipeSearchSuggestion>().having(
          (suggestion) => suggestion.type,
          'type',
          RecipeSearchSuggestionType.recipe,
        ),
      ),
    );
  });
}

const _recipes = [
  RecipeModel(
    id: 'tomato-soup',
    title: 'Tomato Soup',
    categoryId: 'soups',
    categoryName: 'Soups',
    author: 'Ana Cook',
    minutes: 15,
    rating: 4.8,
    accentColor: Color(0xFFAA0000),
    tags: ['vegan', 'quick'],
  ),
  RecipeModel(
    id: 'slow-stew',
    title: 'Slow Stew',
    categoryId: 'dinner',
    categoryName: 'Dinner',
    author: 'Ben Chef',
    minutes: 90,
    rating: 4.6,
    accentColor: Color(0xFF00AA00),
    tags: ['comfort-food'],
  ),
];
