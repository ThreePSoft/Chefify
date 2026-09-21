import 'package:frontend/core/routing/slug.dart';
import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/features/recipes/data/recipe_catalog.dart';
import 'package:frontend/shared/models/home_models.dart';

class RecipeFormOptions {
  RecipeFormOptions._();

  static List<String> availableTags({required bool usesMockData}) {
    if (!usesMockData) {
      return const [];
    }
    final tags = <String>{};
    for (final recipe in RecipeCatalog.items) {
      tags.addAll(recipe.tags);
    }

    return tags.toList(growable: false)..sort(
      (left, right) => _readableLabel(left).compareTo(_readableLabel(right)),
    );
  }

  static List<CategoryModel> get categories => CategoryCatalog.items;

  static String readableTagLabel(String tag) {
    return _readableLabel(tag);
  }

  static String slug(String value) {
    return createSlug(value);
  }

  static String _readableLabel(String value) {
    return value
        .split(RegExp(r'[-_\s]+'))
        .where((part) => part.trim().isNotEmpty)
        .map((part) {
          final normalized = part.trim();
          return normalized[0].toUpperCase() + normalized.substring(1);
        })
        .join(' ');
  }
}
