part of '../../pages/recipe_details_page.dart';

String _descriptionFor(RecipeModel recipe) {
  final description = recipe.description.trim();
  if (description.isNotEmpty) {
    return description;
  }

  return 'A practical Chefify recipe built for repeat cooking, balanced flavor, and a clean weeknight workflow.';
}

String _difficultyLabel(RecipeModel recipe) {
  final difficulty = recipe.difficulty.clamp(1, 5);

  if (difficulty <= 2) {
    return 'Easy';
  }
  if (difficulty == 3) {
    return 'Medium';
  }
  if (difficulty == 4) {
    return 'Hard';
  }
  return 'Expert';
}

String _difficultyText(RecipeModel recipe) {
  final difficulty = recipe.difficulty.clamp(1, 5);

  if (difficulty <= 2) {
    return 'Quick and low-friction for busy days.';
  }
  if (difficulty == 3) {
    return 'Comfortable weeknight cooking with a few focused steps.';
  }
  if (difficulty == 4) {
    return 'Best when you have a little more room for prep and finishing.';
  }
  return 'A more involved cook for confident, detail-focused sessions.';
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
