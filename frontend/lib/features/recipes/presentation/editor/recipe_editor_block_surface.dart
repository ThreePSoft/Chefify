part of '../pages/recipe_create_page.dart';

class _RecipeEditorBlockCard extends StatelessWidget {
  const _RecipeEditorBlockCard({
    required this.dragData,
    required this.block,
    required this.selectedBlockId,
    required this.hoveredBlockId,
    required this.parentBlockId,
    required this.depth,
    this.avoidAuthorOverlay = false,
    required this.canDropBlock,
    required this.onDropBlock,
    required this.onBlockSelected,
    required this.onBlockTitleChanged,
    required this.onBlockBodyChanged,
    required this.onBlockQuoteAuthorChanged,
    required this.onBlockHeightChanged,
    required this.onBlockChanged,
    required this.onDeleteBlock,
  });

  final _RecipeBlockDragData dragData;
  final _RecipeEditorBlock block;
  final String? selectedBlockId;
  final _RecipeBlockHoverController hoveredBlockId;
  final String? parentBlockId;
  final int depth;
  final bool avoidAuthorOverlay;
  final bool Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  canDropBlock;
  final void Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  onDropBlock;
  final ValueChanged<String> onBlockSelected;
  final void Function(String blockId, String title) onBlockTitleChanged;
  final void Function(String blockId, String body) onBlockBodyChanged;
  final void Function(String blockId, String author) onBlockQuoteAuthorChanged;
  final void Function(String blockId, double height) onBlockHeightChanged;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;
  final ValueChanged<String> onDeleteBlock;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthFactor = switch (block.width) {
          _RecipeBlockWidth.narrow => 0.56,
          _RecipeBlockWidth.normal => 0.78,
          _RecipeBlockWidth.wide => 0.92,
          _RecipeBlockWidth.full => 1.0,
        };
        final effectiveWidthFactor = constraints.maxWidth < 420
            ? 1.0
            : widthFactor;
        final blockWidth = constraints.maxWidth * effectiveWidthFactor;
        final blockLeft = switch (block.alignment) {
          _RecipeBlockAlignment.left => 0.0,
          _RecipeBlockAlignment.center =>
            (constraints.maxWidth - blockWidth) / 2,
          _RecipeBlockAlignment.right => constraints.maxWidth - blockWidth,
        };
        final blockRight = blockLeft + blockWidth;
        final authorCenterX =
            constraints.maxWidth -
            _recipeAuthorCardOffset -
            (_recipeAuthorCardExtent / 2);
        final authorRotatedHalfWidth =
            (_recipeAuthorCardExtent / 2) *
            (math.cos(_recipeAuthorCardAngle).abs() +
                math.sin(_recipeAuthorCardAngle).abs());
        final authorLeft = authorCenterX - authorRotatedHalfWidth;
        final overlapInset = blockRight - authorLeft + AppSpacing.sm;
        final deleteButtonInset =
            avoidAuthorOverlay &&
                constraints.maxWidth >= 600 &&
                overlapInset > 0
            ? overlapInset.clamp(0.0, math.max(0.0, blockWidth - 80)).toDouble()
            : 0.0;
        final alignment = switch (block.alignment) {
          _RecipeBlockAlignment.left => Alignment.centerLeft,
          _RecipeBlockAlignment.center => Alignment.center,
          _RecipeBlockAlignment.right => Alignment.centerRight,
        };

        return Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: blockWidth),
            child: _RecipeEditorBlockSurface(
              dragData: dragData,
              block: block,
              selectedBlockId: selectedBlockId,
              hoveredBlockId: hoveredBlockId,
              parentBlockId: parentBlockId,
              depth: depth,
              deleteButtonInset: deleteButtonInset,
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
          ),
        );
      },
    );
  }
}

class _RecipeEditorBlockSurface extends StatefulWidget {
  const _RecipeEditorBlockSurface({
    required this.dragData,
    required this.block,
    required this.selectedBlockId,
    required this.hoveredBlockId,
    required this.parentBlockId,
    required this.depth,
    required this.deleteButtonInset,
    required this.canDropBlock,
    required this.onDropBlock,
    required this.onBlockSelected,
    required this.onBlockTitleChanged,
    required this.onBlockBodyChanged,
    required this.onBlockQuoteAuthorChanged,
    required this.onBlockHeightChanged,
    required this.onBlockChanged,
    required this.onDeleteBlock,
  });

  final _RecipeBlockDragData dragData;
  final _RecipeEditorBlock block;
  final String? selectedBlockId;
  final _RecipeBlockHoverController hoveredBlockId;
  final String? parentBlockId;
  final int depth;
  final double deleteButtonInset;
  final bool Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  canDropBlock;
  final void Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  onDropBlock;
  final ValueChanged<String> onBlockSelected;
  final void Function(String blockId, String title) onBlockTitleChanged;
  final void Function(String blockId, String body) onBlockBodyChanged;
  final void Function(String blockId, String author) onBlockQuoteAuthorChanged;
  final void Function(String blockId, double height) onBlockHeightChanged;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;
  final ValueChanged<String> onDeleteBlock;

  @override
  State<_RecipeEditorBlockSurface> createState() =>
      _RecipeEditorBlockSurfaceState();
}

class _RecipeEditorBlockSurfaceState extends State<_RecipeEditorBlockSurface> {
  static const double _minimumEditorHeight = 72;

  final GlobalKey _surfaceKey = GlobalKey();
  double? _dragHeight;

  _RecipeBlockDragData get dragData => widget.dragData;
  _RecipeEditorBlock get block => widget.block;
  String? get selectedBlockId => widget.selectedBlockId;
  _RecipeBlockHoverController get hoveredBlockId => widget.hoveredBlockId;
  String? get parentBlockId => widget.parentBlockId;
  int get depth => widget.depth;
  double get deleteButtonInset => widget.deleteButtonInset;
  bool Function(_RecipeEditorDragData, _RecipeBlockDropTarget)
  get canDropBlock => widget.canDropBlock;
  void Function(_RecipeEditorDragData, _RecipeBlockDropTarget)
  get onDropBlock => widget.onDropBlock;
  ValueChanged<String> get onBlockSelected => widget.onBlockSelected;
  void Function(String, String) get onBlockTitleChanged =>
      widget.onBlockTitleChanged;
  void Function(String, String) get onBlockBodyChanged =>
      widget.onBlockBodyChanged;
  void Function(String, String) get onBlockQuoteAuthorChanged =>
      widget.onBlockQuoteAuthorChanged;
  void Function(String, double) get onBlockHeightChanged =>
      widget.onBlockHeightChanged;
  ValueChanged<_RecipeEditorBlock> get onBlockChanged => widget.onBlockChanged;
  ValueChanged<String> get onDeleteBlock => widget.onDeleteBlock;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selected = selectedBlockId == block.id;
    final padding = switch (block.spacing) {
      _RecipeBlockSpacing.compact => AppSpacing.sm,
      _RecipeBlockSpacing.normal => depth == 0 ? AppSpacing.md : AppSpacing.sm,
      _RecipeBlockSpacing.spacious => AppSpacing.lg,
    };
    final gap = switch (block.spacing) {
      _RecipeBlockSpacing.compact => AppSpacing.xs,
      _RecipeBlockSpacing.normal => AppSpacing.sm,
      _RecipeBlockSpacing.spacious => AppSpacing.md,
    };
    final background = switch (block.variant) {
      _RecipeBlockVariant.simple => palette.recipeCardBackground.withValues(
        alpha: 0.72,
      ),
      _RecipeBlockVariant.cards => palette.searchBarBackground.withValues(
        alpha: 0.76,
      ),
      _RecipeBlockVariant.timeline => palette.recipeCardBackground.withValues(
        alpha: 0.64,
      ),
    };

    return ConstrainedBox(
      key: _surfaceKey,
      constraints: BoxConstraints(minHeight: block.editorHeight ?? 0),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          MouseRegion(
            key: ValueKey('recipe-editor-block-${block.id}'),
            onEnter: (_) => _setHoveredBlock(block.id),
            onExit: (_) => _setHoveredBlock(parentBlockId),
            child: ValueListenableBuilder<bool>(
              valueListenable: hoveredBlockId.listenableFor(block.id),
              builder: (context, hovered, child) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(end: hovered ? 1 : 0),
                  duration: const Duration(milliseconds: 190),
                  curve: Curves.easeOutCubic,
                  builder: (context, hoverProgress, child) {
                    final hoverBackground = Color.alphaBlend(
                      palette.primaryButtons.withValues(alpha: 0.04),
                      background,
                    );
                    final animatedBackground = Color.lerp(
                      background,
                      hoverBackground,
                      hoverProgress,
                    )!;
                    final restingBorder = selected
                        ? palette.primaryButtons
                        : palette.borders.withValues(alpha: 0.72);
                    final hoverBorder = selected
                        ? palette.primaryButtons
                        : palette.primaryButtons.withValues(alpha: 0.48);
                    final animatedBorder = Color.lerp(
                      restingBorder,
                      hoverBorder,
                      hoverProgress,
                    )!;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onBlockSelected(block.id),
                      child: CustomPaint(
                        foregroundPainter: _RecipeBlockEdgeBorderPainter(
                          color: animatedBorder,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(padding),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                animatedBackground.withValues(alpha: 0),
                                animatedBackground,
                                animatedBackground,
                                animatedBackground.withValues(alpha: 0),
                              ],
                              stops: const [0, 0.18, 0.82, 1],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildPrimaryContent(
                                          context,
                                          palette,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: deleteButtonInset,
                                        ),
                                        child: IconButton(
                                          tooltip: AppStrings.of(
                                            context,
                                          ).deleteBlock,
                                          onPressed: () =>
                                              onDeleteBlock(block.id),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                          ),
                                          iconSize: 18,
                                          visualDensity: VisualDensity.compact,
                                          color: palette.icons,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (selected)
                                    _RecipeActiveBlockTabPortal(
                                      data: dragData,
                                      block: block,
                                      hoveredBlockId: hoveredBlockId,
                                      offset: Offset(
                                        -padding + AppSpacing.sm,
                                        6,
                                      ),
                                    ),
                                ],
                              ),
                              if (_usesSecondaryBody) ...[
                                SizedBox(height: gap / 2),
                                _buildGenericBody(context, palette),
                              ],
                              if (block.canContainChildren) ...[
                                SizedBox(height: gap),
                                _buildChildren(context, gap),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (selected)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 12,
              child: _RecipeBlockResizeHandle(
                blockId: block.id,
                onResizeStart: _startResize,
                onResize: _resizeBy,
                onResizeEnd: _endResize,
              ),
            ),
        ],
      ),
    );
  }

  void _startResize() {
    final renderObject = _surfaceKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      _dragHeight = renderObject.size.height;
    }
  }

  void _resizeBy(double delta) {
    final currentHeight = _dragHeight;
    if (currentHeight == null) {
      return;
    }
    final nextHeight = math.max(_minimumEditorHeight, currentHeight + delta);
    _dragHeight = nextHeight;
    onBlockHeightChanged(block.id, nextHeight);
  }

  void _endResize() {
    _dragHeight = null;
  }

  bool get _usesSecondaryBody {
    return block.kind != _RecipeBlockKind.divider &&
        block.kind != _RecipeBlockKind.image &&
        block.kind != _RecipeBlockKind.video &&
        block.kind != _RecipeBlockKind.note &&
        !block.kind.supportsTextSettings;
  }

  Widget _buildPrimaryContent(BuildContext context, AppPalette palette) {
    return switch (block.kind) {
      _RecipeBlockKind.divider => _buildDividerContent(palette),
      _RecipeBlockKind.heading => _buildTextContentField(
        context,
        palette,
        hintText: AppStrings.of(context).writeHeading,
        style: TextStyle(
          color: palette.mainText,
          fontSize: _textFontSize,
          fontWeight: FontWeight.w900,
          height: 1.12,
        ),
      ),
      _RecipeBlockKind.paragraph => _buildTextContentField(
        context,
        palette,
        hintText: AppStrings.of(context).writeParagraph,
        style: TextStyle(
          color: palette.mainText.withValues(alpha: 0.9),
          fontSize: _textFontSize,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
      ),
      _RecipeBlockKind.quote => _buildQuoteContent(context, palette),
      _RecipeBlockKind.image => _buildImageContent(context, palette),
      _RecipeBlockKind.video => _buildVideoContent(context, palette),
      _RecipeBlockKind.note => _buildNoteContent(context, palette),
      _ => _buildGenericTitle(context, palette),
    };
  }

  Widget _buildGenericTitle(BuildContext context, AppPalette palette) {
    return TextFormField(
      key: ValueKey('${block.id}-title'),
      initialValue: block.title,
      maxLines: 1,
      onTap: () => onBlockSelected(block.id),
      onChanged: (value) => onBlockTitleChanged(block.id, value),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: palette.mainText,
        fontWeight: FontWeight.w900,
      ),
      decoration: _textFieldDecoration(
        palette,
        'Add ${block.kind.label.toLowerCase()} title',
      ),
    );
  }

  Widget _buildGenericBody(BuildContext context, AppPalette palette) {
    return TextFormField(
      key: ValueKey('${block.id}-body'),
      initialValue: block.body,
      minLines: 1,
      maxLines: 4,
      onTap: () => onBlockSelected(block.id),
      onChanged: (value) => onBlockBodyChanged(block.id, value),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: palette.secondaryText,
        height: 1.35,
      ),
      decoration: _textFieldDecoration(
        palette,
        'Write ${block.kind.label.toLowerCase()} content',
      ),
    );
  }

  Widget _buildTextContentField(
    BuildContext context,
    AppPalette palette, {
    required String hintText,
    required TextStyle style,
  }) {
    return TextFormField(
      key: ValueKey('${block.id}-body'),
      initialValue: block.body,
      minLines: 1,
      maxLines: null,
      textAlign: _textAlign,
      onTap: () => onBlockSelected(block.id),
      onChanged: (value) => onBlockBodyChanged(block.id, value),
      style: style,
      decoration: _textFieldDecoration(palette, hintText),
    );
  }

  Widget _buildQuoteContent(BuildContext context, AppPalette palette) {
    final lineOnLeft = block.quoteLineSide == _RecipeQuoteLineSide.left;
    return Container(
      key: ValueKey('${block.id}-quote-surface'),
      padding: EdgeInsets.only(
        left: lineOnLeft ? AppSpacing.md : 0,
        right: lineOnLeft ? 0 : AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: lineOnLeft
              ? BorderSide(color: palette.primaryButtons, width: 3)
              : BorderSide.none,
          right: lineOnLeft
              ? BorderSide.none
              : BorderSide(color: palette.primaryButtons, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextContentField(
            context,
            palette,
            hintText: AppStrings.of(context).writeQuote,
            style: TextStyle(
              color: palette.mainText,
              fontSize: _textFontSize,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            key: ValueKey('${block.id}-quote-author'),
            initialValue: block.quoteAuthor,
            maxLines: 1,
            textAlign: TextAlign.right,
            onTap: () => onBlockSelected(block.id),
            onChanged: (value) => onBlockQuoteAuthorChanged(block.id, value),
            style: TextStyle(
              color: palette.secondaryText,
              fontSize: math.max(12, _textFontSize * 0.72),
              fontWeight: FontWeight.w700,
            ),
            decoration: _textFieldDecoration(
              palette,
              'Quote author (optional)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(BuildContext context, AppPalette palette) {
    return _RecipeImageBlockContent(
      block: block,
      onReplaceFirst: _pickOrReplaceFirstImage,
    );
  }

  Future<void> _pickOrReplaceFirstImage() async {
    final imageUrl = await pickRecipeHeroImageUrl();
    if (imageUrl == null) {
      return;
    }
    if (!mounted) {
      releaseRecipeImageUrl(imageUrl);
      return;
    }

    final imageUrls = [...block.imageUrls];
    if (imageUrls.isEmpty) {
      imageUrls.add(imageUrl);
    } else {
      releaseRecipeImageUrl(imageUrls.first);
      imageUrls[0] = imageUrl;
    }
    onBlockChanged(block.copyWith(imageUrls: imageUrls));
  }

  Widget _buildVideoContent(BuildContext context, AppPalette palette) {
    return _RecipeVideoBlockContent(block: block, onPressed: _editVideoUrl);
  }

  Future<void> _editVideoUrl() async {
    final videoUrl = await showDialog<String>(
      context: context,
      builder: (context) => _RecipeYoutubeUrlDialog(initialUrl: block.videoUrl),
    );
    if (!mounted || videoUrl == null) {
      return;
    }
    onBlockChanged(block.copyWith(videoUrl: videoUrl));
  }

  Widget _buildNoteContent(BuildContext context, AppPalette palette) {
    final (color, icon) = switch (block.noteTone) {
      _RecipeNoteTone.tip => (palette.categoryTags, Icons.lightbulb_outline),
      _RecipeNoteTone.info => (palette.icons, Icons.info_outline_rounded),
      _RecipeNoteTone.warning => (
        palette.primaryButtons,
        Icons.warning_amber_rounded,
      ),
      _RecipeNoteTone.important => (
        Theme.of(context).colorScheme.error,
        Icons.priority_high_rounded,
      ),
    };

    return Container(
      key: ValueKey('${block.id}-note-surface'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextFormField(
              key: ValueKey('${block.id}-body'),
              initialValue: block.body,
              minLines: 1,
              maxLines: null,
              textAlign: _textAlign,
              onTap: () => onBlockSelected(block.id),
              onChanged: (value) => onBlockBodyChanged(block.id, value),
              style: TextStyle(
                color: palette.mainText,
                fontSize: _textFontSize,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
              decoration: _textFieldDecoration(palette, 'Write a note'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDividerContent(AppPalette palette) {
    final colors = _recipeDividerColors(palette);
    return _RecipeDividerPreview(
      style: block.dividerStyle,
      thickness: block.dividerThickness,
      color: colors[block.dividerColorIndex.clamp(0, colors.length - 1)],
    );
  }

  InputDecoration _textFieldDecoration(AppPalette palette, String hintText) {
    return InputDecoration(
      isCollapsed: true,
      filled: false,
      fillColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      hintText: hintText,
      hintStyle: TextStyle(
        color: palette.secondaryText.withValues(alpha: 0.66),
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    );
  }

  TextAlign get _textAlign {
    return switch (block.textAlignment) {
      _RecipeTextAlignment.left => TextAlign.left,
      _RecipeTextAlignment.center => TextAlign.center,
      _RecipeTextAlignment.right => TextAlign.right,
      _RecipeTextAlignment.justify => TextAlign.justify,
    };
  }

  double get _textFontSize {
    if (block.kind == _RecipeBlockKind.heading) {
      return switch (block.textSize) {
        _RecipeTextSize.extraSmall => 18,
        _RecipeTextSize.small => 23,
        _RecipeTextSize.medium => 30,
        _RecipeTextSize.large => 38,
        _RecipeTextSize.extraLarge => 48,
      };
    }

    return switch (block.textSize) {
      _RecipeTextSize.extraSmall => 12,
      _RecipeTextSize.small => 14,
      _RecipeTextSize.medium => 16,
      _RecipeTextSize.large => 19,
      _RecipeTextSize.extraLarge => 23,
    };
  }

  void _setHoveredBlock(String? blockId) {
    hoveredBlockId.activate(blockId);
  }

  Widget _buildChildren(BuildContext context, double gap) {
    final horizontalLayout =
        block.kind == _RecipeBlockKind.columns ||
        block.kind == _RecipeBlockKind.photoText;

    if (!horizontalLayout) {
      return _buildVerticalChildren();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        if (compact) {
          return _buildVerticalChildren();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index <= block.children.length; index++) ...[
              _buildChildDropZone(index, axis: _RecipeDropZoneAxis.horizontal),
              if (index < block.children.length)
                Expanded(child: _buildChildCard(block.children[index], index)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildVerticalChildren() {
    return Column(
      children: [
        for (var index = 0; index <= block.children.length; index++) ...[
          _buildChildDropZone(index),
          if (index < block.children.length)
            _buildChildCard(block.children[index], index),
        ],
      ],
    );
  }

  Widget _buildChildDropZone(
    int index, {
    _RecipeDropZoneAxis axis = _RecipeDropZoneAxis.vertical,
  }) {
    return _RecipeBlockDropZone(
      target: _RecipeBlockDropTarget(
        parentId: block.id,
        index: index,
        depth: depth + 1,
      ),
      canDropBlock: canDropBlock,
      onDropBlock: onDropBlock,
      axis: axis,
    );
  }

  Widget _buildChildCard(_RecipeEditorBlock child, int index) {
    return _RecipeEditorBlockCard(
      dragData: _RecipeBlockDragData(
        blockId: child.id,
        sourceParentId: block.id,
        sourceIndex: index,
        sourceDepth: depth + 1,
      ),
      block: child,
      selectedBlockId: selectedBlockId,
      hoveredBlockId: hoveredBlockId,
      parentBlockId: block.id,
      depth: depth + 1,
      avoidAuthorOverlay: false,
      canDropBlock: canDropBlock,
      onDropBlock: onDropBlock,
      onBlockSelected: onBlockSelected,
      onBlockTitleChanged: onBlockTitleChanged,
      onBlockBodyChanged: onBlockBodyChanged,
      onBlockQuoteAuthorChanged: onBlockQuoteAuthorChanged,
      onBlockHeightChanged: onBlockHeightChanged,
      onBlockChanged: onBlockChanged,
      onDeleteBlock: onDeleteBlock,
    );
  }
}
