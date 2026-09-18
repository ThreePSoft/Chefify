part of '../../pages/recipes_page.dart';

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.sort, required this.onChanged});

  final RecipeSort sort;
  final ValueChanged<RecipeSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return DropdownMenu<RecipeSort>(
      key: const ValueKey('recipes-sort-dropdown'),
      initialSelection: sort,
      expandedInsets: EdgeInsets.zero,
      requestFocusOnTap: false,
      label: Text(strings.sortBy),
      menuHeight: 216,
      dropdownMenuEntries: [
        DropdownMenuEntry(value: RecipeSort.featured, label: strings.featured),
        DropdownMenuEntry(
          value: RecipeSort.rating,
          label: strings.highestRated,
        ),
        DropdownMenuEntry(value: RecipeSort.quickest, label: strings.quickest),
        const DropdownMenuEntry(value: RecipeSort.title, label: 'A-Z'),
      ],
      onSelected: (value) {
        if (value == null) {
          return;
        }
        onChanged(value);
      },
    );
  }
}

class _SavedOnlyButton extends StatelessWidget {
  const _SavedOnlyButton({required this.selected, required this.onChanged});

  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final icon = selected
        ? Icons.bookmark_rounded
        : Icons.bookmark_border_rounded;
    final label = Text(
      strings.savedOnly,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );

    if (selected) {
      return FilledButton.icon(
        onPressed: () => onChanged(false),
        icon: Icon(icon, size: 18),
        label: label,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => onChanged(true),
      icon: Icon(icon, size: 18),
      label: label,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
    );
  }
}

class _CategoryFilterCloud extends StatelessWidget {
  const _CategoryFilterCloud({
    required this.categories,
    required this.selectedCategoryIds,
    required this.onCategoryToggled,
  });

  final List<CategoryModel> categories;
  final Set<String> selectedCategoryIds;
  final ValueChanged<String> onCategoryToggled;

  @override
  Widget build(BuildContext context) {
    final sortedCategories = [...categories]
      ..sort((left, right) {
        final count = right.recipesCount.compareTo(left.recipesCount);
        if (count != 0) {
          return count;
        }

        return left.title.compareTo(right.title);
      });
    final atLimit =
        selectedCategoryIds.length >= _RecipesPageState._maxSelectedCategories;

    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = _buildCategoryChipRows(
          context,
          sortedCategories,
          constraints.maxWidth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: rowIndex == rows.length - 1 ? 0 : AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    for (
                      var itemIndex = 0;
                      itemIndex < rows[rowIndex].length;
                      itemIndex++
                    ) ...[
                      if (itemIndex > 0) const SizedBox(width: AppSpacing.xs),
                      SizedBox(
                        width: rows[rowIndex][itemIndex].width,
                        child: _CategoryFilterChip(
                          category: rows[rowIndex][itemIndex].category,
                          selected: selectedCategoryIds.contains(
                            rows[rowIndex][itemIndex].category.id,
                          ),
                          atLimit: atLimit,
                          onCategoryToggled: onCategoryToggled,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  List<List<_CategoryChipLayout>> _buildCategoryChipRows(
    BuildContext context,
    List<CategoryModel> categories,
    double maxWidth,
  ) {
    final safeWidth = maxWidth.isFinite ? maxWidth : AppSpacing.contentMaxWidth;
    final rows = <List<_CategoryChipSeed>>[];
    var currentRow = <_CategoryChipSeed>[];
    var currentWidth = 0.0;

    for (final category in categories) {
      final baseWidth = _categoryChipBaseWidth(context, category, safeWidth);
      final nextWidth =
          currentWidth + (currentRow.isEmpty ? 0 : AppSpacing.xs) + baseWidth;

      if (currentRow.isNotEmpty && nextWidth > safeWidth) {
        rows.add(currentRow);
        currentRow = [_CategoryChipSeed(category, baseWidth)];
        currentWidth = baseWidth;
      } else {
        currentRow.add(_CategoryChipSeed(category, baseWidth));
        currentWidth = nextWidth;
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return [for (final row in rows) _justifyCategoryChipRow(row, safeWidth)];
  }

  List<_CategoryChipLayout> _justifyCategoryChipRow(
    List<_CategoryChipSeed> row,
    double maxWidth,
  ) {
    final spacing = AppSpacing.xs * (row.length - 1);
    final baseWidth = row.fold<double>(0, (sum, item) => sum + item.baseWidth);
    final extra = (maxWidth - spacing - baseWidth).clamp(0, double.infinity);
    final extraPerChip = row.length <= 1 ? 0.0 : extra / row.length;

    return [
      for (final item in row)
        _CategoryChipLayout(
          category: item.category,
          width: item.baseWidth + extraPerChip,
        ),
    ];
  }

  double _categoryChipBaseWidth(
    BuildContext context,
    CategoryModel category,
    double maxWidth,
  ) {
    final label = '${category.title} ${category.recipesCount}';
    final textStyle =
        Theme.of(context).textTheme.labelLarge ??
        DefaultTextStyle.of(context).style;
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    return (textPainter.width + 72).clamp(118, maxWidth).toDouble();
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.category,
    required this.selected,
    required this.atLimit,
    required this.onCategoryToggled,
  });

  final CategoryModel category;
  final bool selected;
  final bool atLimit;
  final ValueChanged<String> onCategoryToggled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = selected || !atLimit;
    final borderRadius = BorderRadius.circular(AppSpacing.radiusSm);
    final textStyle = Theme.of(context).textTheme.labelLarge;
    final foregroundColor = enabled
        ? palette.mainText
        : palette.secondaryText.withValues(alpha: 0.58);
    final accentColor = enabled
        ? palette.primaryButtons
        : palette.primaryButtons.withValues(alpha: 0.45);
    final borderColor = selected
        ? palette.primaryButtons
        : palette.mainText.withValues(alpha: enabled ? 0.86 : 0.35);
    final backgroundColor = selected
        ? palette.primaryButtons.withValues(alpha: 0.18)
        : Colors.transparent;

    return Material(
      key: ValueKey('recipes-category-chip-${category.id}'),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? () => onCategoryToggled(category.id) : null,
        borderRadius: borderRadius,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                selected ? Icons.check_rounded : category.icon,
                size: 17,
                color: accentColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  '${category.title} ${category.recipesCount}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle?.copyWith(color: foregroundColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChipSeed {
  const _CategoryChipSeed(this.category, this.baseWidth);

  final CategoryModel category;
  final double baseWidth;
}

class _CategoryChipLayout {
  const _CategoryChipLayout({required this.category, required this.width});

  final CategoryModel category;
  final double width;
}

class _RecipeTimeFilterChip extends StatelessWidget {
  const _RecipeTimeFilterChip({
    required this.label,
    required this.filter,
    required this.selectedFilter,
    required this.onSelected,
  });

  final String label;
  final RecipeTimeFilter filter;
  final RecipeTimeFilter selectedFilter;
  final ValueChanged<RecipeTimeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedFilter == filter,
      onSelected: (_) => onSelected(filter),
    );
  }
}
