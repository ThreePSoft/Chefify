part of '../pages/recipe_create_page.dart';

class _RecipeEditorCanvas extends StatelessWidget {
  const _RecipeEditorCanvas({
    required this.blocks,
    required this.selectedBlockId,
    required this.hoveredBlockId,
    required this.onBlockSelected,
    required this.onSelectionCleared,
    required this.onBlockTitleChanged,
    required this.onBlockBodyChanged,
    required this.onBlockQuoteAuthorChanged,
    required this.onBlockHeightChanged,
    required this.onBlockChanged,
    required this.onAppendBlockRequested,
    required this.canDropBlock,
    required this.onDropBlock,
    required this.onDeleteBlock,
  });

  final List<_RecipeEditorBlock> blocks;
  final String? selectedBlockId;
  final _RecipeBlockHoverController hoveredBlockId;
  final ValueChanged<String> onBlockSelected;
  final VoidCallback onSelectionCleared;
  final void Function(String blockId, String title) onBlockTitleChanged;
  final void Function(String blockId, String body) onBlockBodyChanged;
  final void Function(String blockId, String author) onBlockQuoteAuthorChanged;
  final void Function(String blockId, double height) onBlockHeightChanged;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;
  final VoidCallback onAppendBlockRequested;
  final bool Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  canDropBlock;
  final void Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  onDropBlock;
  final ValueChanged<String> onDeleteBlock;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 52),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            key: const ValueKey('recipe-editor-canvas'),
            behavior: HitTestBehavior.opaque,
            onTap: onSelectionCleared,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: palette.cardsSurface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: palette.borders.withValues(alpha: 0.72),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < blocks.length; index++) ...[
                    _RecipeBlockDropZone(
                      target: _RecipeBlockDropTarget(
                        parentId: null,
                        index: index,
                        depth: 0,
                      ),
                      canDropBlock: canDropBlock,
                      onDropBlock: onDropBlock,
                    ),
                    _RecipeEditorBlockCard(
                      dragData: _RecipeBlockDragData(
                        blockId: blocks[index].id,
                        sourceParentId: null,
                        sourceIndex: index,
                        sourceDepth: 0,
                      ),
                      block: blocks[index],
                      selectedBlockId: selectedBlockId,
                      hoveredBlockId: hoveredBlockId,
                      parentBlockId: null,
                      depth: 0,
                      avoidAuthorOverlay: index == 0,
                      canDropBlock: canDropBlock,
                      onDropBlock: onDropBlock,
                      onBlockSelected: onBlockSelected,
                      onBlockTitleChanged: onBlockTitleChanged,
                      onBlockBodyChanged: onBlockBodyChanged,
                      onBlockQuoteAuthorChanged: onBlockQuoteAuthorChanged,
                      onBlockHeightChanged: onBlockHeightChanged,
                      onBlockChanged: onBlockChanged,
                      onDeleteBlock: onDeleteBlock,
                    ),
                  ],
                  _RecipeBlockInsertZone(
                    target: _RecipeBlockDropTarget(
                      parentId: null,
                      index: blocks.length,
                      depth: 0,
                    ),
                    onPressed: onAppendBlockRequested,
                    canDropBlock: canDropBlock,
                    onDropBlock: onDropBlock,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: _recipeAuthorCardOffset,
            right: _recipeAuthorCardOffset,
            child: Transform.rotate(
              angle: _recipeAuthorCardAngle,
              child: const _RecipeLockedAuthorBlock(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeLockedAuthorBlock extends StatefulWidget {
  const _RecipeLockedAuthorBlock();

  @override
  State<_RecipeLockedAuthorBlock> createState() =>
      _RecipeLockedAuthorBlockState();
}

class _RecipeLockedAuthorBlockState extends State<_RecipeLockedAuthorBlock> {
  static const _avatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=320&q=82';

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: _recipeAuthorCardExtent,
        height: _recipeAuthorCardExtent,
        decoration: BoxDecoration(
          color: palette.navbarBackground.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: _hovered
                ? palette.primaryButtons.withValues(alpha: 0.74)
                : palette.borders.withValues(alpha: 0.74),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.3 : 0.2),
              blurRadius: _hovered ? 28 : 20,
              offset: Offset(0, _hovered ? 14 : 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    ClipOval(
                      child: SizedBox.square(
                        dimension: 78,
                        child: Image.network(
                          _avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                                color: palette.primaryButtons.withValues(
                                  alpha: 0.2,
                                ),
                                child: Center(
                                  child: Text(
                                    'CS',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: palette.primaryButtons,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Chef Sofia',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: palette.mainText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '24 recipes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _RecipeAuthorMoreButton(),
          ],
        ),
      ),
    );
  }
}

class _RecipeAuthorMoreButton extends StatefulWidget {
  const _RecipeAuthorMoreButton();

  @override
  State<_RecipeAuthorMoreButton> createState() =>
      _RecipeAuthorMoreButtonState();
}

class _RecipeAuthorMoreButtonState extends State<_RecipeAuthorMoreButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 46,
        color: _hovered
            ? palette.primaryButtons.withValues(alpha: 0.28)
            : palette.searchBarBackground.withValues(alpha: 0.82),
        alignment: Alignment.center,
        child: Text(
          'More recipes',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: _hovered ? palette.primaryButtons : palette.mainText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
