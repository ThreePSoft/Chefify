part of '../recipe_card.dart';

int _cacheDimension(
  double logicalPixels,
  double devicePixelRatio, {
  required int max,
}) {
  if (!logicalPixels.isFinite || logicalPixels <= 0) {
    return max;
  }

  return (logicalPixels * devicePixelRatio).round().clamp(1, max).toInt();
}

double _authorChipMaxWidth(double cardWidth) {
  if (!cardWidth.isFinite || cardWidth <= 0) {
    return 156;
  }

  return (cardWidth - 88).clamp(44.0, 164.0).toDouble();
}

String _authorInitials(String author) {
  final words = author
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  if (words.isEmpty) {
    return '?';
  }

  if (words.length == 1) {
    return words.first[0].toUpperCase();
  }

  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}

String _formatRecipeTag(String tag) {
  final words = tag
      .trim()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);

  return words
      .map((word) {
        if (word.length == 1) {
          return word.toUpperCase();
        }

        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      })
      .join(' ');
}

void _openRecipeTagFilter(BuildContext context, String tag) {
  Navigator.of(context).pushNamed(
    AppRouter.recipes,
    arguments: RecipesPageArguments(tagIds: [tag]),
  );
}

String _tagKey(String tag) {
  return tag
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
