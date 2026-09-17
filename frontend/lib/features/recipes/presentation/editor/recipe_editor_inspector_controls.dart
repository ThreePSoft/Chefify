part of '../pages/recipe_create_page.dart';

class _RecipeInspectorDropdown<T extends Object> extends StatelessWidget {
  const _RecipeInspectorDropdown({
    this.controlKey,
    required this.label,
    required this.value,
    required this.values,
    required this.labelForValue,
    required this.onChanged,
  });

  final String? controlKey;
  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelForValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<T>(
          key: ValueKey(
            controlKey ?? 'recipe-dropdown-$label-${value.hashCode}',
          ),
          initialValue: value,
          isExpanded: true,
          dropdownColor: palette.navbarBackground,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: palette.searchBarBackground.withValues(alpha: 0.72),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
          ),
          items: [
            for (final option in values)
              DropdownMenuItem(
                value: option,
                child: Text(labelForValue(option)),
              ),
          ],
          onChanged: (nextValue) {
            if (nextValue != null) {
              onChanged(nextValue);
            }
          },
        ),
      ],
    );
  }
}

class _RecipeQuoteLineSideButton extends StatelessWidget {
  const _RecipeQuoteLineSideButton({
    required this.side,
    required this.selected,
    required this.onPressed,
  });

  final _RecipeQuoteLineSide side;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final left = side == _RecipeQuoteLineSide.left;

    return Tooltip(
      message: left ? 'Line on left' : 'Line on right',
      child: Material(
        key: ValueKey('recipe-quote-line-${side.name}'),
        color: selected
            ? palette.primaryButtons.withValues(alpha: 0.24)
            : palette.searchBarBackground.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: SizedBox(
            height: 40,
            child: Icon(
              left ? Icons.border_left_rounded : Icons.border_right_rounded,
              size: 20,
              color: selected ? palette.primaryButtons : palette.icons,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeTextAlignmentButton extends StatelessWidget {
  const _RecipeTextAlignmentButton({
    required this.alignment,
    required this.selected,
    required this.onPressed,
  });

  final _RecipeTextAlignment alignment;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (icon, tooltip) = switch (alignment) {
      _RecipeTextAlignment.left => (Icons.format_align_left_rounded, 'Left'),
      _RecipeTextAlignment.center => (
        Icons.format_align_center_rounded,
        'Center',
      ),
      _RecipeTextAlignment.right => (Icons.format_align_right_rounded, 'Right'),
      _RecipeTextAlignment.justify => (
        Icons.format_align_justify_rounded,
        'Justify',
      ),
    };

    return Tooltip(
      message: tooltip,
      child: Material(
        key: ValueKey('recipe-text-align-${alignment.name}'),
        color: selected
            ? palette.primaryButtons.withValues(alpha: 0.24)
            : palette.searchBarBackground.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: SizedBox(
            height: 40,
            child: Icon(
              icon,
              size: 19,
              color: selected ? palette.primaryButtons : palette.icons,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeInspectorEmptyState extends StatelessWidget {
  const _RecipeInspectorEmptyState({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Select a block to edit presets.',
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
    );
  }
}

class _RecipeInspectorRuleNote extends StatelessWidget {
  const _RecipeInspectorRuleNote({required this.block});

  final _RecipeEditorBlock block;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = block.canContainChildren
        ? 'This layout block can contain child blocks.'
        : 'Content blocks cannot contain nested blocks.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: palette.borders.withValues(alpha: 0.58)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: palette.icons),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.secondaryText,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipePresetSelector<T extends Object> extends StatelessWidget {
  const _RecipePresetSelector({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelForValue,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T selected;
  final String Function(T value) labelForValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final value in values)
              ChoiceChip(
                label: Text(labelForValue(value)),
                selected: value == selected,
                onSelected: (_) => onSelected(value),
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: value == selected
                      ? palette.mainText
                      : palette.secondaryText,
                  fontWeight: FontWeight.w800,
                ),
                selectedColor: palette.primaryButtons.withValues(alpha: 0.24),
                backgroundColor: palette.searchBarBackground.withValues(
                  alpha: 0.62,
                ),
                side: BorderSide(
                  color: value == selected
                      ? palette.primaryButtons
                      : palette.borders.withValues(alpha: 0.58),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
