part of '../../pages/recipe_details_page.dart';

class _RecipeOverviewPanel extends StatelessWidget {
  const _RecipeOverviewPanel({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 760;
          final summary = _RecipeOverviewColumn(recipe: recipe);
          final notes = _RecipeNotesColumn(recipe: recipe);

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: AppSpacing.xl),
                notes,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: summary),
              const SizedBox(width: AppSpacing.xl),
              Expanded(child: notes),
            ],
          );
        },
      ),
    );
  }
}

class _RecipeOverviewColumn extends StatelessWidget {
  const _RecipeOverviewColumn({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return _RecipeTextSection(
      eyebrow: 'OVERVIEW',
      title: 'Cook profile',
      children: [
        _RecipeDetailRow(
          icon: Icons.timer_rounded,
          title: 'Time',
          text: '${recipe.minutes} minutes from prep to plate.',
        ),
        _RecipeDetailRow(
          icon: Icons.local_fire_department_rounded,
          title: 'Difficulty',
          text: _difficultyText(recipe),
        ),
        _RecipeDetailRow(
          icon: Icons.insights_rounded,
          title: 'Rating',
          text: '${recipe.rating.toStringAsFixed(1)} average community rating.',
        ),
      ],
    );
  }
}

class _RecipeNotesColumn extends StatelessWidget {
  const _RecipeNotesColumn({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return _RecipeTextSection(
      eyebrow: 'NOTES',
      title: 'What to expect',
      children: [
        _RecipeDetailRow(
          icon: Icons.restaurant_menu_rounded,
          title: recipe.categoryName,
          text: _descriptionFor(recipe),
        ),
        _RecipeDetailRow(
          icon: Icons.bookmark_added_rounded,
          title: 'Save for later',
          text:
              'Use the bookmark button to keep this recipe in your saved list.',
        ),
      ],
    );
  }
}

class _RecipeTextSection extends StatelessWidget {
  const _RecipeTextSection({
    required this.eyebrow,
    required this.title,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: palette.categoryTags,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.lg),
        ...children,
      ],
    );
  }
}

class _RecipeDetailRow extends StatelessWidget {
  const _RecipeDetailRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: palette.searchBarBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: palette.borders),
            ),
            child: Icon(icon, size: 18, color: palette.icons),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeMetaChip extends StatelessWidget {
  const _RecipeMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: palette.icons),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: palette.mainText,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCategoryChip extends StatelessWidget {
  const _RecipeCategoryChip({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.primaryButtons.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category.icon, size: 16, color: palette.primaryButtons),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              category.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: palette.mainText,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
