part of '../../pages/recipe_details_page.dart';

class _RecipeDetailsContent extends StatelessWidget {
  const _RecipeDetailsContent({
    required this.recipe,
    required this.likesCount,
    required this.reviews,
    required this.onReviewSubmitted,
    required this.showDemoReviews,
  });

  final RecipeModel recipe;
  final int likesCount;
  final List<RecipeReview> reviews;
  final void Function(int rating, String comment) onReviewSubmitted;
  final bool showDemoReviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('recipe-details-page-${recipe.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeHeroPanel(recipe: recipe, likesCount: likesCount),
        const SizedBox(height: AppSpacing.lg),
        _RecipeOverviewPanel(recipe: recipe),
        if (showDemoReviews) ...[
          const SizedBox(height: AppSpacing.lg),
          _RecipeReviewsSection(
            recipe: recipe,
            reviews: reviews,
            onReviewSubmitted: onReviewSubmitted,
          ),
        ],
      ],
    );
  }
}

class _RecipeHeroPanel extends StatelessWidget {
  const _RecipeHeroPanel({required this.recipe, required this.likesCount});

  static const double _desktopHeight = 400;
  static const double _compactHeight = 720;

  final RecipeModel recipe;
  final int likesCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      padding: EdgeInsets.zero,
      radius: AppSpacing.radiusLg,
      backgroundColor: palette.navbarBackground,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final panelPadding = compact ? AppSpacing.lg : AppSpacing.xl;

            return SizedBox(
              height: compact ? _compactHeight : _desktopHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _RecipeDetailImage(recipe: recipe),
                  _RecipeHeroGradientOverlay(compact: compact),
                  Positioned(
                    top: panelPadding,
                    right: panelPadding,
                    child: _RecipeDetailsBookmarkButton(recipe: recipe),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(panelPadding),
                      child: _RecipeHeroDetails(
                        recipe: recipe,
                        likesCount: likesCount,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecipeDetailImage extends StatelessWidget {
  const _RecipeDetailImage({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe.imageUrl?.trim();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl == null || imageUrl.isEmpty)
          _RecipeDetailImageFallback(recipe: recipe)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
              final cacheWidth = _cacheDimension(
                constraints.maxWidth,
                devicePixelRatio,
                max: 1400,
              );
              final cacheHeight = _cacheDimension(
                constraints.maxHeight,
                devicePixelRatio,
                max: 900,
              );
              return OptimizedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                cacheWidth: cacheWidth,
                cacheHeight: cacheHeight,
                quality: 78,
                errorBuilder: (context, error, stackTrace) {
                  return _RecipeDetailImageFallback(recipe: recipe);
                },
              );
            },
          ),
      ],
    );
  }
}

class _RecipeHeroGradientOverlay extends StatelessWidget {
  const _RecipeHeroGradientOverlay({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: compact ? Alignment.topCenter : Alignment.centerLeft,
              end: compact ? Alignment.bottomCenter : Alignment.centerRight,
              colors: [
                Colors.black.withValues(alpha: compact ? 0.36 : 0.3),
                palette.navbarBackground.withValues(
                  alpha: compact ? 0.72 : 0.78,
                ),
                palette.navbarBackground.withValues(
                  alpha: compact ? 0.98 : 0.99,
                ),
              ],
              stops: compact ? const [0, 0.44, 1] : const [0, 0.52, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: compact ? const Alignment(0.2, -0.74) : Alignment.center,
              radius: compact ? 1.1 : 0.95,
              colors: [
                Colors.white.withValues(alpha: 0.06),
                Colors.transparent,
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                palette.pageBackground.withValues(alpha: 0.26),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipeDetailImageFallback extends StatelessWidget {
  const _RecipeDetailImageFallback({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            recipe.accentColor.withValues(alpha: 0.95),
            recipe.accentColor.withValues(alpha: 0.56),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 72,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _RecipeHeroDetails extends StatelessWidget {
  const _RecipeHeroDetails({required this.recipe, required this.likesCount});

  final RecipeModel recipe;
  final int likesCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final tight = constraints.maxHeight < 380;
        final metricsWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth * 0.28).clamp(300.0, 340.0).toDouble();
        final contentWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - metricsWidth - AppSpacing.xl)
                  .clamp(360.0, 640.0)
                  .toDouble();
        final titleStyle =
            (compact
                    ? Theme.of(context).textTheme.headlineMedium
                    : Theme.of(context).textTheme.displayMedium)
                ?.copyWith(fontSize: compact ? 34 : 46);
        final descriptionStyle = Theme.of(context).textTheme.bodyLarge
            ?.copyWith(fontSize: compact ? 16 : 18, height: 1.45);

        final tagsBottomOffset = compact ? 160.0 : 0.0;

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: compact ? 0 : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: tight ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _descriptionFor(recipe, AppStrings.of(context)),
                      maxLines: compact ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: descriptionStyle,
                    ),
                  ],
                ),
              ),
            ),
            if (recipe.tags.isNotEmpty)
              Positioned(
                left: 0,
                bottom: tagsBottomOffset,
                right: compact ? 0 : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: _RecipeHeroTagGrid(tags: recipe.tags),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              left: compact ? 0 : null,
              child: Align(
                alignment: compact
                    ? Alignment.bottomLeft
                    : Alignment.bottomRight,
                child: SizedBox(
                  width: metricsWidth,
                  child: _RecipeHeroMetrics(
                    recipe: recipe,
                    likesCount: likesCount,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecipeHeroTagGrid extends StatelessWidget {
  const _RecipeHeroTagGrid({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xxs,
        children: [for (final tag in tags) _RecipeHeroTagChip(tag: tag)],
      ),
    );
  }
}

class _RecipeHeroTagChip extends StatelessWidget {
  const _RecipeHeroTagChip({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Text(
        _readableLabel(tag),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: palette.mainText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RecipeHeroMetrics extends StatelessWidget {
  const _RecipeHeroMetrics({required this.recipe, required this.likesCount});

  final RecipeModel recipe;
  final int likesCount;

  @override
  Widget build(BuildContext context) {
    final category = _categoryFor(recipe);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 340.0;
        final narrow = width < 300;
        final timeChip = _RecipeMetaChip(
          icon: Icons.schedule_rounded,
          label: '${recipe.minutes} min',
        );
        final difficultyChip = _RecipeMetaChip(
          icon: Icons.local_fire_department_rounded,
          label: _difficultyLabel(recipe, AppStrings.of(context)),
        );
        final categoryChip = category == null
            ? _RecipeMetaChip(
                icon: Icons.restaurant_menu_rounded,
                label: recipe.categoryName,
              )
            : _RecipeCategoryChip(category: category);
        final likesChip = _RecipeMetaChip(
          icon: Icons.favorite_rounded,
          label: _formatCount(likesCount),
        );
        final ratingChip = _RecipeMetaChip(
          icon: Icons.star_rounded,
          label: recipe.rating.toStringAsFixed(1),
        );

        final stackedMetrics = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            timeChip,
            const SizedBox(height: AppSpacing.xs),
            difficultyChip,
            const SizedBox(height: AppSpacing.xs),
            categoryChip,
            const SizedBox(height: AppSpacing.xs),
            likesChip,
            const SizedBox(height: AppSpacing.xs),
            ratingChip,
          ],
        );

        final groupedMetrics = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: timeChip),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: difficultyChip),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            categoryChip,
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(child: likesChip),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: ratingChip),
              ],
            ),
          ],
        );

        if (narrow) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: stackedMetrics,
          );
        }

        return groupedMetrics;
      },
    );
  }
}

class _RecipeDetailsBookmarkButton extends StatelessWidget {
  const _RecipeDetailsBookmarkButton({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    final bookmarks = BookmarkScope.of(context);
    final isSaved = bookmarks.isRecipeSaved(recipe);

    return BookmarkButton(
      isSaved: isSaved,
      onPressed: () {
        bookmarks.toggleRecipe(recipe);
      },
    );
  }
}
