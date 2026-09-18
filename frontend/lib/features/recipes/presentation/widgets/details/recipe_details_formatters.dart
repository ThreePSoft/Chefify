part of '../../pages/recipe_details_page.dart';

String _descriptionFor(RecipeModel recipe, AppStrings strings) {
  final description = recipe.description.trim();
  if (description.isNotEmpty) {
    return description;
  }

  return strings.defaultRecipeDescription;
}

String _difficultyLabel(RecipeModel recipe, AppStrings strings) {
  final difficulty = recipe.difficulty.clamp(1, 5);

  if (difficulty <= 2) {
    return strings.easy;
  }
  if (difficulty == 3) {
    return strings.medium;
  }
  if (difficulty == 4) {
    return strings.hard;
  }
  return strings.expert;
}

String _difficultyText(RecipeModel recipe, AppStrings strings) {
  final difficulty = recipe.difficulty.clamp(1, 5);

  if (difficulty <= 2) {
    return strings.easyDifficultyDescription;
  }
  if (difficulty == 3) {
    return strings.mediumDifficultyDescription;
  }
  if (difficulty == 4) {
    return strings.hardDifficultyDescription;
  }
  return strings.expertDifficultyDescription;
}

String _formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}m';
  }
  if (value >= 1000) {
    final formatted = value / 1000;
    return '${formatted.toStringAsFixed(formatted >= 10 ? 0 : 1)}k';
  }
  return value.toString();
}

String _readableLabel(String value) {
  final words = value
      .trim()
      .split(RegExp(r'[-_\s]+'))
      .where((word) => word.isNotEmpty);

  return words
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

String _initials(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  if (words.isEmpty) {
    return 'CH';
  }

  return words.take(2).map((word) => word[0].toUpperCase()).join();
}

String _formatReviewDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');

  return '$day.$month.$year $hour:$minute';
}

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
