import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/routing/slug.dart';
import 'package:frontend/shared/models/home_models.dart';

void main() {
  group('createSlug', () {
    test('keeps Ukrainian letters and normalizes separators', () {
      expect(createSlug(' Борщ по-українськи! '), 'борщ-по-українськи');
      expect(createSlug('Марія Іваненко'), 'марія-іваненко');
    });

    test('keeps letters and numbers from other writing systems', () {
      expect(createSlug('Crème brûlée 2'), 'crème-brûlée-2');
      expect(createSlug('東京 2026'), '東京-2026');
    });

    test('provides a deterministic fallback for symbol-only values', () {
      expect(createSlug('🍲'), 'item-1f372');
      expect(createSlug('   '), 'item');
    });
  });

  test('author paths preserve a non-empty Unicode slug', () {
    expect(
      AppRouter.authorProfilePath('Марія Іваненко'),
      '/authors/${Uri.encodeComponent('марія-іваненко')}',
    );
  });

  test('recipe JSON fallback IDs support Ukrainian titles', () {
    final recipe = RecipeModel.fromJson(<String, dynamic>{
      'title': 'Сирники з вишнею',
      'categoryName': 'Українська кухня',
    });

    expect(recipe.id, 'сирники-з-вишнею');
    expect(recipe.categoryId, 'українська-кухня');
  });
}
