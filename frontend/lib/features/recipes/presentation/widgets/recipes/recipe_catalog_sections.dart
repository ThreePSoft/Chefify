part of '../../pages/recipes_page.dart';

class _RecipesHeader extends StatelessWidget {
  const _RecipesHeader({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECIPES',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: palette.categoryTags,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;

            final title = Text(
              'Find your next cook',
              style: compact
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.displayMedium,
            );

            final count = _RecipeCountBadge(totalCount: totalCount);

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: AppSpacing.sm),
                  count,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: title),
                const SizedBox(width: AppSpacing.lg),
                count,
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Browse every Chefify recipe and narrow the list by taste, time, saved items, or rating.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _RecipeCountBadge extends StatelessWidget {
  const _RecipeCountBadge({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Text(
        '$totalCount recipes',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _RecipesGrid extends StatelessWidget {
  const _RecipesGrid({
    required this.recipes,
    required this.topPadding,
    required this.bottomPadding,
  });

  final List<RecipeModel> recipes;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ResponsiveSliverGrid<RecipeModel>(
      items: recipes,
      minItemWidth: 240,
      maxColumns: 4,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      itemHeightBuilder: _recipeCardHeight,
      itemBuilder: (context, recipe) {
        return RecipeCard(
          key: ValueKey('recipes-card-${recipe.id}'),
          recipe: recipe,
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRouter.recipeDetailsPath(recipe.id),
              arguments: recipe,
            );
          },
        );
      },
    );
  }
}

double _recipeCardHeight(double width, int columns) {
  if (columns == 1 || width < 280) {
    return 350;
  }

  return 364;
}

class _RecipesContentSliver extends StatelessWidget {
  const _RecipesContentSliver({
    required this.child,
    this.topPadding = 0,
    this.bottomPadding = 0,
  });

  final Widget child;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = AppSpacing.horizontalPaddingForWidth(
      viewportWidth,
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          topPadding,
          horizontalPadding,
          bottomPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _RecipePagination extends StatelessWidget {
  const _RecipePagination({
    required this.currentPage,
    required this.pageCount,
    required this.onPageChanged,
  });

  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final pages = _visiblePages;

    return Center(
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _PaginationIconButton(
            icon: Icons.chevron_left_rounded,
            enabled: currentPage > 1,
            onPressed: () => onPageChanged(currentPage - 1),
          ),
          for (var index = 0; index < pages.length; index++) ...[
            if (index > 0 && pages[index] - pages[index - 1] > 1)
              const _PaginationGap(),
            _PaginationPageButton(
              page: pages[index],
              selected: pages[index] == currentPage,
              onPressed: () => onPageChanged(pages[index]),
            ),
          ],
          _PaginationIconButton(
            icon: Icons.chevron_right_rounded,
            enabled: currentPage < pageCount,
            onPressed: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }

  List<int> get _visiblePages {
    if (pageCount <= 7) {
      return [for (var page = 1; page <= pageCount; page++) page];
    }

    final pages = <int>{1, pageCount};
    for (var page = currentPage - 1; page <= currentPage + 1; page++) {
      if (page > 1 && page < pageCount) {
        pages.add(page);
      }
    }

    return pages.toList()..sort();
  }
}

class _PaginationPageButton extends StatelessWidget {
  const _PaginationPageButton({
    required this.page,
    required this.selected,
    required this.onPressed,
  });

  final int page;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final child = Text('$page', overflow: TextOverflow.ellipsis);

    if (selected) {
      return SizedBox.square(
        dimension: 42,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox.square(
      dimension: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _PaginationIconButton extends StatelessWidget {
  const _PaginationIconButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 42,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),
    );
  }
}

class _PaginationGap extends StatelessWidget {
  const _PaginationGap();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 42,
      child: Center(
        child: Text('...', style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}

class _EmptyRecipesState extends StatelessWidget {
  const _EmptyRecipesState();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.manage_search_rounded, size: 40, color: palette.icons),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No recipes match these filters',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Try a different search term, category, or cook time.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipesHeaderShell extends StatelessWidget {
  const _RecipesHeaderShell({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: palette.navbarBackground.withValues(alpha: 0.94),
          border: Border(
            bottom: BorderSide(color: palette.borders.withValues(alpha: 0.55)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
