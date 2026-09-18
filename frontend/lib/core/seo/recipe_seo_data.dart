class RecipeSeoData {
  const RecipeSeoData({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.category,
    required this.cookMinutes,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final String author;
  final String category;
  final int cookMinutes;
  final String? imageUrl;

  Map<String, Object> structuredData({required String pageUrl}) {
    return <String, Object>{
      '@context': 'https://schema.org',
      '@type': 'Recipe',
      'name': title,
      'description': description,
      'author': <String, Object>{'@type': 'Person', 'name': author},
      'recipeCategory': category,
      'cookTime': 'PT${cookMinutes.clamp(0, 14400)}M',
      'url': pageUrl,
      if (imageUrl case final imageUrl? when imageUrl.trim().isNotEmpty)
        'image': <String>[imageUrl.trim()],
    };
  }
}
