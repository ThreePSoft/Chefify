part of '../../pages/recipe_details_page.dart';

class _RecipeNotFound extends StatelessWidget {
  const _RecipeNotFound({required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      key: ValueKey('recipe-details-not-found-$recipeId'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 44, color: palette.icons),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Recipe not found',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'This recipe is not available in the current catalog.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/recipes', (route) => false);
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Browse recipes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeDetailsContentSliver extends StatelessWidget {
  const _RecipeDetailsContentSliver({
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

class _RecipeDetailsHeaderShell extends StatelessWidget {
  const _RecipeDetailsHeaderShell({required this.height, required this.child});

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

class _RecipeStickyActionButton extends StatelessWidget {
  const _RecipeStickyActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final activeColor = const Color(0xFFD96D58);
    final background = isActive
        ? activeColor
        : palette.cardsSurface.withValues(alpha: 0.94);
    final foreground = isActive ? Colors.white : palette.mainText;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? activeColor.withValues(alpha: 0.72)
                    : palette.borders.withValues(alpha: 0.84),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: foreground),
          ),
        ),
      ),
    );
  }
}

CategoryModel? _categoryFor(RecipeModel recipe) {
  return CategoryCatalog.findById(recipe.categoryId) ??
      CategoryCatalog.findById(recipe.categoryName);
}
