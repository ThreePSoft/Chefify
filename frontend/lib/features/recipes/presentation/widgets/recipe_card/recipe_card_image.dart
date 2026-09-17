part of '../recipe_card.dart';

class _RecipeNetworkImage extends StatelessWidget {
  const _RecipeNetworkImage({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = _cacheDimension(
          constraints.maxWidth,
          devicePixelRatio,
          max: 720,
        );
        final cacheHeight = _cacheDimension(
          constraints.maxHeight,
          devicePixelRatio,
          max: 520,
        );

        return OptimizedNetworkImage(
          imageUrl: _recipePreviewImageUrl(recipe)!,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return _RecipeImageFallback(recipe: recipe);
          },
        );
      },
    );
  }
}

String? _recipePreviewImageUrl(RecipeModel recipe) {
  final thumbnailUrl = recipe.thumbnailUrl?.trim();
  if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
    return thumbnailUrl;
  }

  final imageUrl = recipe.imageUrl?.trim();
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return imageUrl;
  }

  return null;
}

class _RecipeImageFallback extends StatelessWidget {
  const _RecipeImageFallback({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            recipe.accentColor.withValues(alpha: 0.9),
            recipe.accentColor.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 52,
          color: Colors.white,
        ),
      ),
    );
  }
}
