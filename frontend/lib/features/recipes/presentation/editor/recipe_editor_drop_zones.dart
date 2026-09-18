part of '../pages/recipe_create_page.dart';

enum _RecipeDropZoneAxis { vertical, horizontal }

class _RecipeBlockDropZone extends StatefulWidget {
  const _RecipeBlockDropZone({
    required this.target,
    required this.canDropBlock,
    required this.onDropBlock,
    this.axis = _RecipeDropZoneAxis.vertical,
  });

  final _RecipeBlockDropTarget target;
  final bool Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  canDropBlock;
  final void Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  onDropBlock;
  final _RecipeDropZoneAxis axis;

  @override
  State<_RecipeBlockDropZone> createState() => _RecipeBlockDropZoneState();
}

class _RecipeBlockDropZoneState extends State<_RecipeBlockDropZone> {
  bool _escapeReady = true;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final target = widget.target;

    return DragTarget<_RecipeEditorDragData>(
      onWillAcceptWithDetails: _handleWillAccept,
      onMove: _handleMove,
      onLeave: (_) => _setEscapeReady(true),
      onAcceptWithDetails: (details) {
        if (_escapeReady && widget.canDropBlock(details.data, target)) {
          widget.onDropBlock(details.data, target);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final hasCandidate = candidateData.isNotEmpty;
        final active = hasCandidate && _escapeReady;
        final invalid =
            (hasCandidate && !_escapeReady) ||
            (!hasCandidate && rejectedData.isNotEmpty);
        final color = invalid
            ? Theme.of(context).colorScheme.error
            : palette.primaryButtons;
        final lineAlpha = active
            ? 0.95
            : invalid
            ? 0.5
            : 0.0;

        if (widget.axis == _RecipeDropZoneAxis.horizontal) {
          return AnimatedContainer(
            key: ValueKey(
              'recipe-drop-zone-${target.parentId ?? 'root'}-${target.index}',
            ),
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOutCubic,
            width: active || invalid ? 22 : 7,
            height: 72,
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              width: active || invalid ? 4 : 0,
              height: active || invalid ? 62 : 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0),
                    color.withValues(alpha: lineAlpha),
                    color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          );
        }

        return AnimatedContainer(
          key: ValueKey(
            'recipe-drop-zone-${target.parentId ?? 'root'}-${target.index}',
          ),
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          height: active || invalid ? 24 : 8,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            width: double.infinity,
            height: active || invalid ? 4 : 0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0),
                  color.withValues(alpha: lineAlpha),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _handleWillAccept(DragTargetDetails<_RecipeEditorDragData> details) {
    final valid = widget.canDropBlock(details.data, widget.target);
    _setEscapeReady(valid && _isEscapeReady(details.data, details.offset));
    return valid;
  }

  void _handleMove(DragTargetDetails<_RecipeEditorDragData> details) {
    _setEscapeReady(_isEscapeReady(details.data, details.offset));
  }

  bool _isEscapeReady(_RecipeEditorDragData data, Offset globalOffset) {
    if (data is! _RecipeBlockDragData) {
      return true;
    }
    final levelsOut = data.sourceDepth - widget.target.depth;
    if (levelsOut <= 0) {
      return true;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return false;
    }
    final localOffset = renderObject.globalToLocal(globalOffset);
    final acceptedFraction = (0.68 - ((levelsOut - 1) * 0.1)).clamp(0.48, 0.68);
    final threshold = renderObject.size.width * acceptedFraction;
    return localOffset.dx <= threshold;
  }

  void _setEscapeReady(bool value) {
    if (_escapeReady == value || !mounted) {
      return;
    }
    setState(() => _escapeReady = value);
  }
}

class _RecipeBlockInsertZone extends StatefulWidget {
  const _RecipeBlockInsertZone({
    required this.target,
    required this.onPressed,
    required this.canDropBlock,
    required this.onDropBlock,
  });

  final _RecipeBlockDropTarget target;
  final VoidCallback onPressed;
  final bool Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  canDropBlock;
  final void Function(_RecipeEditorDragData data, _RecipeBlockDropTarget target)
  onDropBlock;

  @override
  State<_RecipeBlockInsertZone> createState() => _RecipeBlockInsertZoneState();
}

class _RecipeBlockInsertZoneState extends State<_RecipeBlockInsertZone> {
  bool _escapeReady = true;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DragTarget<_RecipeEditorDragData>(
      onWillAcceptWithDetails: (details) {
        final valid = widget.canDropBlock(details.data, widget.target);
        _setEscapeReady(valid && _isEscapeReady(details.data, details.offset));
        return valid;
      },
      onMove: (details) =>
          _setEscapeReady(_isEscapeReady(details.data, details.offset)),
      onLeave: (_) => _setEscapeReady(true),
      onAcceptWithDetails: (details) {
        if (_escapeReady && widget.canDropBlock(details.data, widget.target)) {
          widget.onDropBlock(details.data, widget.target);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final hasCandidate = candidateData.isNotEmpty;
        final active = hasCandidate && _escapeReady;
        final invalid =
            (hasCandidate && !_escapeReady) ||
            (!hasCandidate && rejectedData.isNotEmpty);
        final activeColor = invalid
            ? Theme.of(context).colorScheme.error
            : palette.primaryButtons;

        return Material(
          key: ValueKey(
            'recipe-block-insert-zone-${widget.target.parentId ?? 'root'}-${widget.target.index}',
          ),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: active || invalid ? 96 : 84,
              decoration: BoxDecoration(
                color: active || invalid
                    ? activeColor.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: active || invalid
                      ? activeColor
                      : palette.borders.withValues(alpha: 0.58),
                ),
              ),
              child: Center(
                child: Icon(
                  active
                      ? Icons.vertical_align_center_rounded
                      : Icons.add_rounded,
                  size: active || invalid ? 34 : 32,
                  color: activeColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isEscapeReady(_RecipeEditorDragData data, Offset globalOffset) {
    if (data is! _RecipeBlockDragData) {
      return true;
    }
    final levelsOut = data.sourceDepth - widget.target.depth;
    if (levelsOut <= 0) {
      return true;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return false;
    }
    final localOffset = renderObject.globalToLocal(globalOffset);
    final acceptedFraction = (0.68 - ((levelsOut - 1) * 0.1)).clamp(0.48, 0.68);
    final threshold = renderObject.size.width * acceptedFraction;
    return localOffset.dx <= threshold;
  }

  void _setEscapeReady(bool value) {
    if (_escapeReady == value || !mounted) {
      return;
    }
    setState(() => _escapeReady = value);
  }
}

class _RecipeBlockDragFeedback extends StatelessWidget {
  const _RecipeBlockDragFeedback({required this.block});

  final _RecipeEditorBlock block;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: palette.navbarBackground.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: palette.primaryButtons),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(block.kind.icon, size: 18, color: palette.primaryButtons),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                block.title.isEmpty ? block.kind.label : block.title,
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

class _RecipeBlockDragHandle extends StatelessWidget {
  const _RecipeBlockDragHandle({
    required this.data,
    required this.block,
    required this.hoveredBlockId,
    required this.child,
  });

  final _RecipeBlockDragData data;
  final _RecipeEditorBlock block;
  final _RecipeBlockHoverController hoveredBlockId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Draggable<_RecipeBlockDragData>(
        data: data,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        rootOverlay: true,
        onDragStarted: () => hoveredBlockId.activate(null),
        onDragCompleted: () => hoveredBlockId.activate(null),
        onDraggableCanceled: (_, _) => hoveredBlockId.activate(null),
        feedback: RepaintBoundary(
          child: _RecipeBlockDragFeedback(block: block),
        ),
        childWhenDragging: Opacity(opacity: 0.34, child: child),
        child: child,
      ),
    );
  }
}

class _RecipeActiveBlockTabPortal extends StatefulWidget {
  const _RecipeActiveBlockTabPortal({
    required this.data,
    required this.block,
    required this.hoveredBlockId,
    required this.offset,
  });

  final _RecipeBlockDragData data;
  final _RecipeEditorBlock block;
  final _RecipeBlockHoverController hoveredBlockId;
  final Offset offset;

  @override
  State<_RecipeActiveBlockTabPortal> createState() =>
      _RecipeActiveBlockTabPortalState();
}

class _RecipeActiveBlockTabPortalState
    extends State<_RecipeActiveBlockTabPortal> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();

  @override
  void initState() {
    super.initState();
    _controller.show();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        final viewportWidth = MediaQuery.sizeOf(context).width;
        final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);

        return Positioned(
          left: 0,
          top: headerHeight,
          right: 0,
          bottom: 0,
          child: ClipRect(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: 220,
                  height: 40,
                  child: CompositedTransformFollower(
                    link: _link,
                    showWhenUnlinked: false,
                    targetAnchor: Alignment.topLeft,
                    followerAnchor: Alignment.bottomLeft,
                    offset: widget.offset,
                    child: _RecipeBlockDragHandle(
                      data: widget.data,
                      block: widget.block,
                      hoveredBlockId: widget.hoveredBlockId,
                      child: _RecipeActiveBlockTab(block: widget.block),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: const SizedBox.shrink(),
      ),
    );
  }
}

class _RecipeActiveBlockTab extends StatelessWidget {
  const _RecipeActiveBlockTab({required this.block});

  final _RecipeEditorBlock block;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      key: ValueKey('recipe-editor-block-handle-${block.id}'),
      constraints: const BoxConstraints(minWidth: 132, maxWidth: 220),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.navbarBackground.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusSm),
          topRight: Radius.circular(AppSpacing.radiusSm),
          bottomRight: Radius.circular(AppSpacing.xs),
        ),
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.54),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(block.kind.icon, size: 17, color: palette.primaryButtons),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              block.kind.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette.categoryTags,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
