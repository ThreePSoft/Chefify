part of '../pages/profile_page.dart';

class _ProfileRecipeGrid extends StatelessWidget {
  const _ProfileRecipeGrid({required this.recipes, required this.emptyMessage});

  final List<RecipeModel> recipes;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return AppCard(
        key: const ValueKey('profile-recipes-empty'),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 44,
              color: context.palette.icons,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(emptyMessage, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = AppSpacing.gridColumns(
          width: constraints.maxWidth,
          minItemWidth: 240,
          maxColumns: 4,
        );
        final width = AppSpacing.gridItemWidth(
          width: constraints.maxWidth,
          minItemWidth: 240,
          maxColumns: 4,
        );
        return Wrap(
          key: const ValueKey('profile-recipe-grid'),
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final recipe in recipes)
              SizedBox(
                width: width,
                height: columns == 1 || width < 280 ? 350 : 364,
                child: RecipeCard(
                  key: ValueKey('profile-recipe-${recipe.id}'),
                  recipe: recipe,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRouter.recipeDetailsPath(recipe.id),
                    arguments: recipe,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
