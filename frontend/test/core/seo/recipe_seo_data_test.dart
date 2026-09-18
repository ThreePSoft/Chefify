import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/seo/recipe_seo_data.dart';

void main() {
  test('builds Recipe JSON-LD with normalized cooking duration', () {
    const recipe = RecipeSeoData(
      id: 'syrnyky',
      title: 'Сирники з вишнею',
      description: 'Ніжні сирники для сніданку.',
      author: 'Марія Іваненко',
      category: 'Українська кухня',
      cookMinutes: 35,
      imageUrl: 'https://example.test/syrnyky.jpg',
    );

    expect(
      recipe.structuredData(pageUrl: 'https://chefify.test/recipes/syrnyky'),
      <String, Object>{
        '@context': 'https://schema.org',
        '@type': 'Recipe',
        'name': 'Сирники з вишнею',
        'description': 'Ніжні сирники для сніданку.',
        'author': <String, Object>{'@type': 'Person', 'name': 'Марія Іваненко'},
        'recipeCategory': 'Українська кухня',
        'cookTime': 'PT35M',
        'url': 'https://chefify.test/recipes/syrnyky',
        'image': <String>['https://example.test/syrnyky.jpg'],
      },
    );
  });
}
