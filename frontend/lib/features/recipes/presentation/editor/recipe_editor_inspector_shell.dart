part of '../pages/recipe_create_page.dart';

class _RecipeEditorInspector extends StatefulWidget {
  const _RecipeEditorInspector({
    this.embedded = false,
    required this.block,
    required this.onWidthChanged,
    required this.onAlignmentChanged,
    required this.onSpacingChanged,
    required this.onVariantChanged,
    required this.onTextAlignmentChanged,
    required this.onTextSizeChanged,
    required this.onBlockChanged,
  });

  final bool embedded;
  final _RecipeEditorBlock? block;
  final ValueChanged<_RecipeBlockWidth> onWidthChanged;
  final ValueChanged<_RecipeBlockAlignment> onAlignmentChanged;
  final ValueChanged<_RecipeBlockSpacing> onSpacingChanged;
  final ValueChanged<_RecipeBlockVariant> onVariantChanged;
  final ValueChanged<_RecipeTextAlignment> onTextAlignmentChanged;
  final ValueChanged<_RecipeTextSize> onTextSizeChanged;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  State<_RecipeEditorInspector> createState() => _RecipeEditorInspectorState();
}

class _RecipeEditorInspectorState extends State<_RecipeEditorInspector> {
  _RecipeInspectorTab _activeTab = _RecipeInspectorTab.block;

  bool get embedded => widget.embedded;
  _RecipeEditorBlock? get block => widget.block;
  ValueChanged<_RecipeBlockWidth> get onWidthChanged => widget.onWidthChanged;
  ValueChanged<_RecipeBlockAlignment> get onAlignmentChanged =>
      widget.onAlignmentChanged;
  ValueChanged<_RecipeBlockSpacing> get onSpacingChanged =>
      widget.onSpacingChanged;
  ValueChanged<_RecipeBlockVariant> get onVariantChanged =>
      widget.onVariantChanged;
  ValueChanged<_RecipeTextAlignment> get onTextAlignmentChanged =>
      widget.onTextAlignmentChanged;
  ValueChanged<_RecipeTextSize> get onTextSizeChanged =>
      widget.onTextSizeChanged;
  ValueChanged<_RecipeEditorBlock> get onBlockChanged => widget.onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selectedBlock = block;

    return Container(
      key: ValueKey('recipe-inspector-block-${selectedBlock?.id ?? 'none'}'),
      width: double.infinity,
      padding: embedded ? EdgeInsets.zero : const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: embedded
            ? Colors.transparent
            : palette.cardsSurface.withValues(alpha: 0.72),
        borderRadius: embedded
            ? BorderRadius.zero
            : BorderRadius.circular(AppSpacing.radiusMd),
        border: embedded
            ? null
            : Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: selectedBlock == null
          ? _RecipeInspectorEmptyState(palette: palette)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      selectedBlock.kind.icon,
                      color: palette.primaryButtons,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        selectedBlock.kind.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: palette.mainText,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _RecipeInspectorTabs(
                  selected: _activeTab,
                  onSelected: (tab) => setState(() => _activeTab = tab),
                ),
                const SizedBox(height: AppSpacing.md),
                if (_activeTab == _RecipeInspectorTab.block) ...[
                  _RecipePresetSelector<_RecipeBlockWidth>(
                    label: AppStrings.of(context).width,
                    values: _RecipeBlockWidth.values,
                    selected: selectedBlock.width,
                    labelForValue: _widthLabel,
                    onSelected: onWidthChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RecipePresetSelector<_RecipeBlockAlignment>(
                    label: AppStrings.of(context).alignment,
                    values: _RecipeBlockAlignment.values,
                    selected: selectedBlock.alignment,
                    labelForValue: _alignmentLabel,
                    onSelected: onAlignmentChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RecipePresetSelector<_RecipeBlockSpacing>(
                    label: AppStrings.of(context).spacing,
                    values: _RecipeBlockSpacing.values,
                    selected: selectedBlock.spacing,
                    labelForValue: _spacingLabel,
                    onSelected: onSpacingChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RecipePresetSelector<_RecipeBlockVariant>(
                    label: AppStrings.of(context).variant,
                    values: _RecipeBlockVariant.values,
                    selected: selectedBlock.variant,
                    labelForValue: _variantLabel,
                    onSelected: onVariantChanged,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _RecipeInspectorRuleNote(block: selectedBlock),
                ] else
                  _RecipeTextContentInspector(
                    block: selectedBlock,
                    onAlignmentChanged: onTextAlignmentChanged,
                    onSizeChanged: onTextSizeChanged,
                    onBlockChanged: onBlockChanged,
                  ),
              ],
            ),
    );
  }

  String _widthLabel(_RecipeBlockWidth width) {
    return switch (width) {
      _RecipeBlockWidth.narrow => 'Narrow',
      _RecipeBlockWidth.normal => 'Normal',
      _RecipeBlockWidth.wide => 'Wide',
      _RecipeBlockWidth.full => 'Full',
    };
  }

  String _alignmentLabel(_RecipeBlockAlignment alignment) {
    return switch (alignment) {
      _RecipeBlockAlignment.left => 'Left',
      _RecipeBlockAlignment.center => 'Center',
      _RecipeBlockAlignment.right => 'Right',
    };
  }

  String _spacingLabel(_RecipeBlockSpacing spacing) {
    return switch (spacing) {
      _RecipeBlockSpacing.compact => 'Compact',
      _RecipeBlockSpacing.normal => 'Normal',
      _RecipeBlockSpacing.spacious => 'Spacious',
    };
  }

  String _variantLabel(_RecipeBlockVariant variant) {
    return switch (variant) {
      _RecipeBlockVariant.simple => 'Simple',
      _RecipeBlockVariant.cards => 'Cards',
      _RecipeBlockVariant.timeline => 'Timeline',
    };
  }
}

class _RecipeInspectorTabs extends StatelessWidget {
  const _RecipeInspectorTabs({
    required this.selected,
    required this.onSelected,
  });

  final _RecipeInspectorTab selected;
  final ValueChanged<_RecipeInspectorTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RecipeInspectorTabButton(
            label: AppStrings.of(context).block,
            icon: Icons.crop_free_rounded,
            selected: selected == _RecipeInspectorTab.block,
            onPressed: () => onSelected(_RecipeInspectorTab.block),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _RecipeInspectorTabButton(
            label: AppStrings.of(context).content,
            icon: Icons.text_fields_rounded,
            selected: selected == _RecipeInspectorTab.content,
            onPressed: () => onSelected(_RecipeInspectorTab.content),
          ),
        ),
      ],
    );
  }
}

class _RecipeInspectorTabButton extends StatelessWidget {
  const _RecipeInspectorTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      key: ValueKey('recipe-inspector-tab-${label.toLowerCase()}'),
      color: selected
          ? palette.primaryButtons.withValues(alpha: 0.22)
          : palette.searchBarBackground.withValues(alpha: 0.62),
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? palette.primaryButtons : palette.icons,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? palette.mainText : palette.secondaryText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
