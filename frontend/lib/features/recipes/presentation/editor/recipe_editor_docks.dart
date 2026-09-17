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
                  tooltip: 'Collapse block palette',
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

class _RecipeCompactPalette extends StatelessWidget {
  const _RecipeCompactPalette({
    required this.activeTab,
    required this.templates,
    required this.blocks,
    required this.blockCueAnimation,
    required this.onTabChanged,
    required this.onExpanded,
    required this.onTemplateSelected,
    required this.onBlockSelected,
  });

  final _RecipeEditorTab activeTab;
  final List<_RecipeTemplateDefinition> templates;
  final List<_RecipeBlockDefinition> blocks;
  final Animation<double> blockCueAnimation;
  final ValueChanged<_RecipeEditorTab> onTabChanged;
  final VoidCallback onExpanded;
  final ValueChanged<_RecipeTemplateDefinition> onTemplateSelected;
  final ValueChanged<_RecipeBlockDefinition> onBlockSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RecipeCompactTabButton(
                tooltip: 'Templates',
                icon: Icons.dashboard_customize_rounded,
                selected: activeTab == _RecipeEditorTab.templates,
                onPressed: () => onTabChanged(_RecipeEditorTab.templates),
              ),
              _RecipeCompactTabButton(
                tooltip: 'Blocks',
                icon: Icons.widgets_rounded,
                selected: activeTab == _RecipeEditorTab.blocks,
                onPressed: () => onTabChanged(_RecipeEditorTab.blocks),
              ),
              _RecipeCompactTabButton(
                tooltip: 'Expand block palette',
                icon: Icons.chevron_right_rounded,
                selected: false,
                onPressed: onExpanded,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: activeTab == _RecipeEditorTab.templates
                ? _RecipeCompactTemplateList(
                    templates: templates,
                    onSelected: onTemplateSelected,
                  )
                : _RecipeCompactBlockList(
                    blocks: blocks,
                    cueAnimation: blockCueAnimation,
                    onSelected: onBlockSelected,
                  ),
          ),
        ),
      ],
    );
  }
}

class _RecipeCompactBlockList extends StatelessWidget {
  const _RecipeCompactBlockList({
    required this.blocks,
    required this.cueAnimation,
    required this.onSelected,
  });

  final List<_RecipeBlockDefinition> blocks;
  final Animation<double> cueAnimation;
  final ValueChanged<_RecipeBlockDefinition> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      children: [
        for (final group in _RecipeBlockGroup.values) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 6,
            ),
            child: Divider(
              height: 1,
              color: palette.borders.withValues(alpha: 0.72),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final block in blocks.where(
                  (block) => block.kind.group == group,
                ))
                  _RecipeCompactBlockButton(
                    block: block,
                    cueAnimation: cueAnimation,
                    onPressed: () => onSelected(block),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RecipeCompactBlockButton extends StatelessWidget {
  const _RecipeCompactBlockButton({
    required this.block,
    required this.cueAnimation,
    required this.onPressed,
  });

  final _RecipeBlockDefinition block;
  final Animation<double> cueAnimation;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: block.kind.label,
      child: _RecipePaletteBlockDragSource(
        block: block,
        child: Material(
          color: palette.searchBarBackground.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: SizedBox(
              width: 43,
              height: 42,
              child: FadeTransition(
                key: ValueKey('recipe-palette-cue-${block.kind.name}'),
                opacity: cueAnimation,
                child: Icon(
                  block.kind.icon,
                  size: 20,
                  color: palette.primaryButtons,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipePaletteBlockDragSource extends StatelessWidget {
  const _RecipePaletteBlockDragSource({
    required this.block,
    required this.child,
  });

  final _RecipeBlockDefinition block;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Draggable<_RecipeEditorDragData>(
        key: ValueKey('recipe-palette-drag-${block.kind.name}'),
        data: _RecipePaletteBlockDragData(block),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        rootOverlay: true,
        feedback: _RecipePaletteBlockDragFeedback(block: block),
        childWhenDragging: Opacity(opacity: 0.42, child: child),
        child: child,
      ),
    );
  }
}

class _RecipePaletteBlockDragFeedback extends StatelessWidget {
  const _RecipePaletteBlockDragFeedback({required this.block});

  final _RecipeBlockDefinition block;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 236,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: palette.navbarBackground.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: palette.primaryButtons),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(block.kind.icon, size: 20, color: palette.primaryButtons),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                block.kind.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.mainText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCompactTemplateList extends StatelessWidget {
  const _RecipeCompactTemplateList({
    required this.templates,
    required this.onSelected,
  });

  final List<_RecipeTemplateDefinition> templates;
  final ValueChanged<_RecipeTemplateDefinition> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      children: [
        for (final template in templates)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 4,
            ),
            child: _RecipeTemplatePreviewTarget(
              key: ValueKey('compact-template-${template.title}'),
              template: template,
              child: Material(
                color: palette.searchBarBackground.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: InkWell(
                  onTap: () => onSelected(template),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: SizedBox(
                    width: 80,
                    height: 68,
                    child: Icon(
                      template.icon,
                      size: 28,
                      color: palette.primaryButtons,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecipeTemplatePreviewTarget extends StatefulWidget {
  const _RecipeTemplatePreviewTarget({
    super.key,
    required this.template,
    required this.child,
  });

  final _RecipeTemplateDefinition template;
  final Widget child;

  @override
  State<_RecipeTemplatePreviewTarget> createState() =>
      _RecipeTemplatePreviewTargetState();
}

class _RecipeTemplatePreviewTargetState
    extends State<_RecipeTemplatePreviewTarget> {
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _controller = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) => Positioned(
        top: 0,
        left: 0,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.centerRight,
          followerAnchor: Alignment.centerLeft,
          offset: const Offset(AppSpacing.sm, 0),
          child: _RecipeTemplatePreview(template: widget.template),
        ),
      ),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          onEnter: (_) => _controller.show(),
          onExit: (_) {
            if (_controller.isShowing) {
              _controller.hide();
            }
          },
          child: Semantics(
            label: '${widget.template.title} template',
            button: true,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _RecipeTemplatePreview extends StatelessWidget {
  const _RecipeTemplatePreview({required this.template});

  final _RecipeTemplateDefinition template;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final previewBlocks = template.createBlocks((prefix) => 'preview-$prefix');

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 286,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: palette.navbarBackground.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: palette.primaryButtons.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(template.icon, size: 22, color: palette.primaryButtons),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      template.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: palette.mainText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                template.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.secondaryText,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Divider(color: palette.borders.withValues(alpha: 0.7)),
              const SizedBox(height: AppSpacing.xs),
              for (final block in previewBlocks)
                _RecipeTemplatePreviewBlock(block: block),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeTemplatePreviewBlock extends StatelessWidget {
  const _RecipeTemplatePreviewBlock({required this.block, this.depth = 0});

  final _RecipeEditorBlock block;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: EdgeInsets.only(left: depth * 14, bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(block.kind.icon, size: 16, color: palette.icons),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  block.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.mainText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          for (final child in block.children)
            _RecipeTemplatePreviewBlock(block: child, depth: depth + 1),
        ],
      ),
    );
  }
}

class _RecipeCompactTabButton extends StatelessWidget {
  const _RecipeCompactTabButton({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected
            ? palette.primaryButtons.withValues(alpha: 0.22)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: SizedBox(
            width: 32,
            height: 34,
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
                tooltip: 'Open block settings',
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
                  tooltip: 'Collapse block settings',
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
