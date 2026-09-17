part of '../pages/recipe_create_page.dart';

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
