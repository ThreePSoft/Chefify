part of '../recipe_card.dart';

class _RecipeTagRow extends StatelessWidget {
  const _RecipeTagRow({required this.recipeId, required this.tags});

  final String recipeId;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: palette.mainText,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.1,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final tagLayout = _tagLayoutForWidth(
          context,
          tags,
          constraints.maxWidth,
          textStyle,
        );

        return SizedBox(
          height: 24,
          child: Row(
            children: [
              for (
                var index = 0;
                index < tagLayout.visibleTags.length;
                index++
              ) ...[
                if (index > 0) const SizedBox(width: AppSpacing.xxs),
                _RecipeTagChip(
                  key: ValueKey(
                    'recipe-card-tag-$recipeId-${_tagKey(tagLayout.visibleTags[index].tag)}',
                  ),
                  width: tagLayout.visibleTags[index].width,
                  tag: tagLayout.visibleTags[index].tag,
                  label: tagLayout.visibleTags[index].label,
                  textStyle: textStyle,
                ),
              ],
              if (tagLayout.hasOverflow) ...[
                if (tagLayout.visibleTags.isNotEmpty)
                  const SizedBox(width: AppSpacing.xxs),
                _RecipeOverflowTagChip(
                  recipeId: recipeId,
                  tags: tags,
                  textStyle: textStyle,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  _RecipeTagRowLayout _tagLayoutForWidth(
    BuildContext context,
    List<String> tags,
    double maxWidth,
    TextStyle? textStyle,
  ) {
    if (!maxWidth.isFinite || maxWidth <= 0) {
      return _RecipeTagRowLayout(
        visibleTags: [
          for (final tag in tags.take(2))
            _RecipeTagItem(
              tag: tag,
              label: _formatRecipeTag(tag),
              width: _measureTagWidth(
                context,
                _formatRecipeTag(tag),
                textStyle,
              ),
            ),
        ],
        hasOverflow: tags.length > 2,
      );
    }

    final visibleTags = <_RecipeTagItem>[];
    var usedWidth = 0.0;
    final overflowChipWidth = _measureTagWidth(context, '...', textStyle);

    for (var index = 0; index < tags.length; index++) {
      final tag = tags[index];
      final label = _formatRecipeTag(tag);
      final chipWidth = _measureTagWidth(context, label, textStyle);
      final hasRemainingTags = index < tags.length - 1;
      final leadingSpacing = visibleTags.isEmpty ? 0 : AppSpacing.xxs;
      final overflowReserve = hasRemainingTags
          ? AppSpacing.xxs + overflowChipWidth
          : 0.0;
      final nextWidth =
          usedWidth + leadingSpacing + chipWidth + overflowReserve;

      if (nextWidth > maxWidth) {
        return _RecipeTagRowLayout(visibleTags: visibleTags, hasOverflow: true);
      }

      visibleTags.add(_RecipeTagItem(tag: tag, label: label, width: chipWidth));
      usedWidth += leadingSpacing + chipWidth;
    }

    return _RecipeTagRowLayout(visibleTags: visibleTags);
  }

  double _measureTagWidth(
    BuildContext context,
    String label,
    TextStyle? textStyle,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: textStyle ?? DefaultTextStyle.of(context).style,
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    return (textPainter.width + 20).clamp(36, 118).toDouble();
  }
}

class _RecipeTagRowLayout {
  const _RecipeTagRowLayout({
    required this.visibleTags,
    this.hasOverflow = false,
  });

  final List<_RecipeTagItem> visibleTags;
  final bool hasOverflow;
}

class _RecipeTagItem {
  const _RecipeTagItem({
    required this.tag,
    required this.label,
    required this.width,
  });

  final String tag;
  final String label;
  final double width;
}

class _RecipeOverflowTagChip extends StatefulWidget {
  const _RecipeOverflowTagChip({
    required this.recipeId,
    required this.tags,
    required this.textStyle,
  });

  final String recipeId;
  final List<String> tags;
  final TextStyle? textStyle;

  @override
  State<_RecipeOverflowTagChip> createState() => _RecipeOverflowTagChipState();
}

class _RecipeOverflowTagChipState extends State<_RecipeOverflowTagChip> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _anchorHovered = false;
  bool _popoverHovered = false;
  bool _focused = false;

  bool get _shouldShowOverlay => _anchorHovered || _popoverHovered || _focused;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _setAnchorHovered(true),
        onExit: (_) => _setAnchorHovered(false),
        cursor: SystemMouseCursors.click,
        child: FocusableActionDetector(
          onFocusChange: (focused) {
            setState(() {
              _focused = focused;
            });
            _syncOverlay();
          },
          child: Material(
            color: palette.searchBarBackground.withValues(alpha: 0.76),
            shape: StadiumBorder(
              side: BorderSide(color: palette.borders.withValues(alpha: 0.72)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey('recipe-card-tag-overflow-${widget.recipeId}'),
              onTap: _syncOverlay,
              child: Container(
                height: 24,
                constraints: const BoxConstraints(minWidth: 36),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                child: Text('...', style: widget.textStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setAnchorHovered(bool hovered) {
    setState(() {
      _anchorHovered = hovered;
    });
    _syncOverlay();
  }

  void _setPopoverHovered(bool hovered) {
    if (!mounted) {
      return;
    }

    setState(() {
      _popoverHovered = hovered;
    });
    _syncOverlay();
  }

  void _syncOverlay() {
    if (_shouldShowOverlay) {
      _showOverlay();
      return;
    }

    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (!mounted || _shouldShowOverlay) {
        return;
      }
      _removeOverlay();
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final layout = _popoverOverlayLayout();
        if (layout == null) {
          return const SizedBox.shrink();
        }

        return CompositedTransformFollower(
          link: _layerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(layout.horizontalOffset, AppSpacing.xs),
          showWhenUnlinked: false,
          child: MouseRegion(
            onEnter: (_) => _setPopoverHovered(true),
            onExit: (_) => _setPopoverHovered(false),
            child: Material(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.topLeft,
                widthFactor: 1,
                heightFactor: 1,
                child: _RecipeTagPopover(
                  tags: widget.tags,
                  textStyle: widget.textStyle,
                  onTagSelected: (tag) {
                    _removeOverlay();
                    _openRecipeTagFilter(context, tag);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  _RecipePopoverOverlayLayout? _popoverOverlayLayout() {
    final overlay = Overlay.maybeOf(context);
    final overlayRenderObject = overlay?.context.findRenderObject();
    final anchorRenderObject = context.findRenderObject();
    if (overlayRenderObject is! RenderBox ||
        anchorRenderObject is! RenderBox ||
        !overlayRenderObject.hasSize ||
        !anchorRenderObject.hasSize) {
      return null;
    }

    const margin = AppSpacing.sm;
    final overlayWidth = overlayRenderObject.size.width;
    const popoverWidth = _RecipeTagPopover.width;

    final anchorLeft = anchorRenderObject
        .localToGlobal(Offset.zero, ancestor: overlayRenderObject)
        .dx;
    final minLeft = overlayWidth >= popoverWidth + (margin * 2) ? margin : 0.0;
    final maxLeft = (overlayWidth - popoverWidth - margin)
        .clamp(0.0, double.infinity)
        .toDouble();
    final safeMaxLeft = maxLeft < minLeft ? minLeft : maxLeft;
    final clampedLeft = anchorLeft.clamp(minLeft, safeMaxLeft).toDouble();

    return _RecipePopoverOverlayLayout(
      horizontalOffset: clampedLeft - anchorLeft,
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _RecipePopoverOverlayLayout {
  const _RecipePopoverOverlayLayout({required this.horizontalOffset});

  final double horizontalOffset;
}

class _RecipeTagPopover extends StatelessWidget {
  const _RecipeTagPopover({
    required this.tags,
    required this.textStyle,
    required this.onTagSelected,
  });

  static const double width = 228;

  final List<String> tags;
  final TextStyle? textStyle;
  final ValueChanged<String> onTagSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      key: const ValueKey('recipe-tag-popover'),
      width: _RecipeTagPopover.width,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.cardsSurface.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: palette.borders.withValues(alpha: 0.76)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rows = _buildRows(context, constraints.maxWidth);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
                Row(
                  children: [
                    for (
                      var index = 0;
                      index < rows[rowIndex].length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        flex: rows[rowIndex][index].flex,
                        child: _RecipeTagChip(
                          fillWidth: true,
                          tag: rows[rowIndex][index].tag,
                          label: rows[rowIndex][index].label,
                          textStyle: textStyle,
                          textAlign: TextAlign.center,
                          onSelected: onTagSelected,
                        ),
                      ),
                    ],
                  ],
                ),
                if (rowIndex < rows.length - 1)
                  const SizedBox(height: AppSpacing.xxs),
              ],
            ],
          );
        },
      ),
    );
  }

  List<List<_RecipePopoverTagItem>> _buildRows(
    BuildContext context,
    double maxWidth,
  ) {
    final safeWidth = maxWidth.isFinite && maxWidth > 0 ? maxWidth : 202.0;
    final rows = <List<_RecipePopoverTagItem>>[];
    var currentRow = <_RecipePopoverTagItem>[];
    var currentWidth = 0.0;

    for (final tag in tags) {
      final label = _formatRecipeTag(tag);
      final baseWidth = _measurePopoverTagWidth(context, label);
      final nextWidth =
          currentWidth + (currentRow.isEmpty ? 0 : AppSpacing.xxs) + baseWidth;

      if (currentRow.isNotEmpty &&
          (currentRow.length >= 3 || nextWidth > safeWidth)) {
        rows.add(currentRow);
        currentRow = [_RecipePopoverTagItem(tag, label, baseWidth)];
        currentWidth = baseWidth;
      } else {
        currentRow.add(_RecipePopoverTagItem(tag, label, baseWidth));
        currentWidth = nextWidth;
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return rows;
  }

  double _measurePopoverTagWidth(BuildContext context, String label) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: textStyle ?? DefaultTextStyle.of(context).style,
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    return (textPainter.width + 22).clamp(58, 118).toDouble();
  }
}

class _RecipeTagChip extends StatelessWidget {
  const _RecipeTagChip({
    super.key,
    this.width,
    this.fillWidth = false,
    required this.tag,
    required this.label,
    required this.textStyle,
    this.textAlign = TextAlign.start,
    this.onSelected,
  });

  final double? width;
  final bool fillWidth;
  final String tag;
  final String label;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.searchBarBackground.withValues(alpha: 0.76),
      shape: StadiumBorder(
        side: BorderSide(color: palette.borders.withValues(alpha: 0.72)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final handler = onSelected;
          if (handler != null) {
            handler(tag);
            return;
          }

          _openRecipeTagFilter(context, tag);
        },
        mouseCursor: SystemMouseCursors.click,
        child: Container(
          width: fillWidth ? double.infinity : width,
          constraints: width == null
              ? const BoxConstraints(maxWidth: 118)
              : const BoxConstraints(),
          alignment: width == null ? Alignment.centerLeft : Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}

class _RecipePopoverTagItem {
  const _RecipePopoverTagItem(this.tag, this.label, this.width);

  final String tag;
  final String label;
  final double width;

  int get flex => (width * 100).round().clamp(1, 100000);
}
