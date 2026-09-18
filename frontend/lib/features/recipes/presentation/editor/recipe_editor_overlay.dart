part of '../pages/recipe_create_page.dart';

class _RecipeEditorOverlay extends StatelessWidget {
  const _RecipeEditorOverlay({
    required this.activeTab,
    required this.paletteExpanded,
    required this.inspectorExpanded,
    required this.blockPaletteCue,
    required this.templates,
    required this.blocks,
    required this.selectedBlock,
    required this.onTabChanged,
    required this.onPaletteExpandedChanged,
    required this.onInspectorExpandedChanged,
    required this.onTemplateSelected,
    required this.onBlockSelected,
    required this.onWidthChanged,
    required this.onAlignmentChanged,
    required this.onSpacingChanged,
    required this.onVariantChanged,
    required this.onTextAlignmentChanged,
    required this.onTextSizeChanged,
    required this.onBlockChanged,
  });

  final _RecipeEditorTab activeTab;
  final bool paletteExpanded;
  final bool inspectorExpanded;
  final int blockPaletteCue;
  final List<_RecipeTemplateDefinition> templates;
  final List<_RecipeBlockDefinition> blocks;
  final _RecipeEditorBlock? selectedBlock;
  final ValueChanged<_RecipeEditorTab> onTabChanged;
  final ValueChanged<bool> onPaletteExpandedChanged;
  final ValueChanged<bool> onInspectorExpandedChanged;
  final ValueChanged<_RecipeTemplateDefinition> onTemplateSelected;
  final ValueChanged<_RecipeBlockDefinition> onBlockSelected;
  final ValueChanged<_RecipeBlockWidth> onWidthChanged;
  final ValueChanged<_RecipeBlockAlignment> onAlignmentChanged;
  final ValueChanged<_RecipeBlockSpacing> onSpacingChanged;
  final ValueChanged<_RecipeBlockVariant> onVariantChanged;
  final ValueChanged<_RecipeTextAlignment> onTextAlignmentChanged;
  final ValueChanged<_RecipeTextSize> onTextSizeChanged;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
    final top = headerHeight + AppSpacing.sm;

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          top: top,
          bottom: AppSpacing.sm,
          left: paletteExpanded ? AppSpacing.sm : 0,
          child: _RecipePaletteDock(
            expanded: paletteExpanded,
            activeTab: activeTab,
            blockPaletteCue: blockPaletteCue,
            templates: templates,
            blocks: blocks,
            onExpandedChanged: onPaletteExpandedChanged,
            onTabChanged: onTabChanged,
            onTemplateSelected: onTemplateSelected,
            onBlockSelected: onBlockSelected,
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          top: top,
          height: inspectorExpanded
              ? MediaQuery.sizeOf(context).height - top - AppSpacing.sm
              : 52,
          right: inspectorExpanded ? AppSpacing.sm : 0,
          child: _RecipeInspectorDock(
            expanded: inspectorExpanded,
            block: selectedBlock,
            onExpandedChanged: onInspectorExpandedChanged,
            onWidthChanged: onWidthChanged,
            onAlignmentChanged: onAlignmentChanged,
            onSpacingChanged: onSpacingChanged,
            onVariantChanged: onVariantChanged,
            onTextAlignmentChanged: onTextAlignmentChanged,
            onTextSizeChanged: onTextSizeChanged,
            onBlockChanged: onBlockChanged,
          ),
        ),
      ],
    );
  }
}

class _RecipePaletteDock extends StatefulWidget {
  const _RecipePaletteDock({
    required this.expanded,
    required this.activeTab,
    required this.blockPaletteCue,
    required this.templates,
    required this.blocks,
    required this.onExpandedChanged,
    required this.onTabChanged,
    required this.onTemplateSelected,
    required this.onBlockSelected,
  });

  final bool expanded;
  final _RecipeEditorTab activeTab;
  final int blockPaletteCue;
  final List<_RecipeTemplateDefinition> templates;
  final List<_RecipeBlockDefinition> blocks;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<_RecipeEditorTab> onTabChanged;
  final ValueChanged<_RecipeTemplateDefinition> onTemplateSelected;
  final ValueChanged<_RecipeBlockDefinition> onBlockSelected;

  @override
  State<_RecipePaletteDock> createState() => _RecipePaletteDockState();
}

class _RecipePaletteDockState extends State<_RecipePaletteDock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cueController;
  late final Animation<double> _blockCueAnimation;

  bool get expanded => widget.expanded;
  _RecipeEditorTab get activeTab => widget.activeTab;
  List<_RecipeTemplateDefinition> get templates => widget.templates;
  List<_RecipeBlockDefinition> get blocks => widget.blocks;
  ValueChanged<bool> get onExpandedChanged => widget.onExpandedChanged;
  ValueChanged<_RecipeEditorTab> get onTabChanged => widget.onTabChanged;
  ValueChanged<_RecipeTemplateDefinition> get onTemplateSelected =>
      widget.onTemplateSelected;
  ValueChanged<_RecipeBlockDefinition> get onBlockSelected =>
      widget.onBlockSelected;

  @override
  void initState() {
    super.initState();
    _cueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: 1,
    );
    _blockCueAnimation = TweenSequence<double>([
      for (var index = 0; index < 3; index++) ...[
        TweenSequenceItem(
          tween: Tween(
            begin: 1.0,
            end: 0.28,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 0.28,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 1,
        ),
      ],
    ]).animate(_cueController);
  }

  @override
  void didUpdateWidget(covariant _RecipePaletteDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blockPaletteCue != widget.blockPaletteCue) {
      _cueController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _cueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: expanded ? 292 : 112,
      decoration: BoxDecoration(
        color: palette.navbarBackground.withValues(
          alpha: expanded ? 0.9 : 0.96,
        ),
        borderRadius: expanded
            ? BorderRadius.circular(AppSpacing.radiusMd)
            : const BorderRadius.horizontal(
                right: Radius.circular(AppSpacing.radiusMd),
              ),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showExpandedContent = expanded && constraints.maxWidth >= 270;
          if (!showExpandedContent) {
            return _RecipeCompactPalette(
              activeTab: activeTab,
              templates: templates,
              blocks: blocks,
              blockCueAnimation: _blockCueAnimation,
              onTabChanged: onTabChanged,
              onExpanded: () => onExpandedChanged(true),
              onTemplateSelected: onTemplateSelected,
              onBlockSelected: onBlockSelected,
            );
          }

          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: AppStrings.of(context).collapseBlockPalette,
                  onPressed: () => onExpandedChanged(false),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    0,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: _RecipeEditorPalette(
                    embedded: true,
                    activeTab: activeTab,
                    templates: templates,
                    blocks: blocks,
                    blockCueAnimation: _blockCueAnimation,
                    onTabChanged: onTabChanged,
                    onTemplateSelected: onTemplateSelected,
                    onBlockSelected: onBlockSelected,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecipeInspectorDock extends StatelessWidget {
  const _RecipeInspectorDock({
    required this.expanded,
    required this.block,
    required this.onExpandedChanged,
    required this.onWidthChanged,
    required this.onAlignmentChanged,
    required this.onSpacingChanged,
    required this.onVariantChanged,
    required this.onTextAlignmentChanged,
    required this.onTextSizeChanged,
    required this.onBlockChanged,
  });

  final bool expanded;
  final _RecipeEditorBlock? block;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<_RecipeBlockWidth> onWidthChanged;
  final ValueChanged<_RecipeBlockAlignment> onAlignmentChanged;
  final ValueChanged<_RecipeBlockSpacing> onSpacingChanged;
  final ValueChanged<_RecipeBlockVariant> onVariantChanged;
  final ValueChanged<_RecipeTextAlignment> onTextAlignmentChanged;
  final ValueChanged<_RecipeTextSize> onTextSizeChanged;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: expanded ? 292 : 52,
      decoration: BoxDecoration(
        color: palette.navbarBackground.withValues(
          alpha: expanded ? 0.9 : 0.96,
        ),
        borderRadius: expanded
            ? BorderRadius.circular(AppSpacing.radiusMd)
            : const BorderRadius.horizontal(
                left: Radius.circular(AppSpacing.radiusMd),
              ),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showExpandedContent = expanded && constraints.maxWidth >= 270;
          if (!showExpandedContent) {
            return Center(
              child: IconButton(
                tooltip: AppStrings.of(context).openBlockSettings,
                onPressed: () => onExpandedChanged(true),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                icon: const Icon(Icons.tune_rounded),
              ),
            );
          }

          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: AppStrings.of(context).collapseBlockSettings,
                  onPressed: () => onExpandedChanged(false),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    0,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: _RecipeEditorInspector(
                    embedded: true,
                    block: block,
                    onWidthChanged: onWidthChanged,
                    onAlignmentChanged: onAlignmentChanged,
                    onSpacingChanged: onSpacingChanged,
                    onVariantChanged: onVariantChanged,
                    onTextAlignmentChanged: onTextAlignmentChanged,
                    onTextSizeChanged: onTextSizeChanged,
                    onBlockChanged: onBlockChanged,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
