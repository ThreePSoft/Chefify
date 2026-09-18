part of '../pages/recipe_create_page.dart';

class _RecipeCreateMetaPanel extends StatelessWidget {
  const _RecipeCreateMetaPanel({
    required this.duration,
    required this.difficulty,
    required this.category,
    required this.onEditDuration,
    required this.onEditDifficulty,
    required this.onEditCategory,
  });

  final _RecipeDurationValue duration;
  final String difficulty;
  final CategoryModel? category;
  final VoidCallback onEditDuration;
  final VoidCallback onEditDifficulty;
  final VoidCallback onEditCategory;

  @override
  Widget build(BuildContext context) {
    final hasMultiUnitDuration = duration.activeUnitCount > 1;
    final durationChip = _RecipeCreateMetaChip(
      key: const ValueKey('recipe-duration-chip'),
      icon: Icons.schedule_rounded,
      label: duration.label,
      onPressed: onEditDuration,
      isEditable: true,
    );
    final difficultyChip = _RecipeCreateMetaChip(
      icon: Icons.local_fire_department_rounded,
      label: difficulty,
      onPressed: onEditDifficulty,
      isEditable: true,
    );

    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasMultiUnitDuration) ...[
            SizedBox(width: double.infinity, child: durationChip),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(width: double.infinity, child: difficultyChip),
          ] else
            Row(
              children: [
                Expanded(child: durationChip),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: difficultyChip),
              ],
            ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            child: _RecipeCreateMetaChip(
              icon: category?.icon ?? Icons.restaurant_menu_rounded,
              label: category?.title ?? 'Category',
              onPressed: onEditCategory,
              isEditable: true,
              isHighlighted: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _RecipeCreateMetaChip(
                  icon: Icons.favorite_rounded,
                  label: '0',
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _RecipeCreateMetaChip(
                  icon: Icons.star_rounded,
                  label: '0.0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipeCreateMetaChip extends StatelessWidget {
  const _RecipeCreateMetaChip({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.isEditable = false,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isEditable;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foregroundColor = isHighlighted
        ? palette.primaryButtons
        : palette.icons;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isHighlighted
                ? palette.primaryButtons.withValues(alpha: 0.14)
                : palette.searchBarBackground.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isHighlighted
                  ? palette.primaryButtons.withValues(alpha: 0.42)
                  : palette.borders.withValues(alpha: 0.72),
            ),
          ),
          child: Row(
            children: [
              if (isEditable) const SizedBox(width: 15),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16, color: foregroundColor),
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
              ),
              if (isEditable)
                SizedBox(
                  width: 15,
                  child: Icon(
                    Icons.edit_rounded,
                    size: 13,
                    color: palette.secondaryText.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
