part of '../pages/recipe_create_page.dart';

class _RecipeCreateTagRow extends StatefulWidget {
  const _RecipeCreateTagRow({
    required this.tags,
    required this.isAddingTag,
    required this.tagController,
    required this.tagFocusNode,
    required this.tagSuggestions,
    required this.onSubmitTag,
    required this.onRemoveTag,
    required this.onAddTagPressed,
    required this.onCancelTagInput,
  });

  final List<String> tags;
  final bool isAddingTag;
  final TextEditingController tagController;
  final FocusNode tagFocusNode;
  final List<String> tagSuggestions;
  final ValueChanged<String> onSubmitTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onAddTagPressed;
  final VoidCallback onCancelTagInput;

  @override
  State<_RecipeCreateTagRow> createState() => _RecipeCreateTagRowState();
}

class _RecipeCreateTagRowState extends State<_RecipeCreateTagRow> {
  final GlobalKey _tagInputAnchorKey = GlobalKey();
  OverlayEntry? _suggestionsOverlay;

  @override
  void didUpdateWidget(covariant _RecipeCreateTagRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleSuggestionsOverlaySync();
  }

  @override
  void dispose() {
    _removeSuggestionsOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleSuggestionsOverlaySync();

    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = _buildRows(context, constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (
                    var itemIndex = 0;
                    itemIndex < rows[rowIndex].length;
                    itemIndex++
                  ) ...[
                    if (itemIndex > 0) const SizedBox(width: AppSpacing.xs),
                    SizedBox(
                      width: rows[rowIndex][itemIndex].width,
                      child: _buildTagItem(rows[rowIndex][itemIndex].item),
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
    );
  }

  List<List<_RecipeCreateTagLayout>> _buildRows(
    BuildContext context,
    double maxWidth,
  ) {
    final safeWidth = maxWidth.isFinite && maxWidth > 0
        ? maxWidth
        : AppSpacing.contentMaxWidth;
    final seeds = _buildSeeds(context, safeWidth);
    final rows = <List<_RecipeCreateTagSeed>>[];
    var currentRow = <_RecipeCreateTagSeed>[];
    var currentWidth = 0.0;

    for (final seed in seeds) {
      final nextWidth =
          currentWidth + (currentRow.isEmpty ? 0 : AppSpacing.xs) + seed.width;

      if (currentRow.isNotEmpty && nextWidth > safeWidth) {
        rows.add(currentRow);
        currentRow = [seed];
        currentWidth = seed.width;
      } else {
        currentRow.add(seed);
        currentWidth = nextWidth;
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    if (rows.isEmpty) {
      return const [];
    }

    final targetWidth = rows
        .map(_rowWidth)
        .fold<double>(0, (largest, width) => width > largest ? width : largest)
        .clamp(0, safeWidth)
        .toDouble();

    return [for (final row in rows) _justifyRow(row, targetWidth)];
  }

  List<_RecipeCreateTagSeed> _buildSeeds(
    BuildContext context,
    double maxWidth,
  ) {
    return [
      for (final tag in widget.tags)
        _RecipeCreateTagSeed(
          _RecipeCreateTagItem.tag(tag),
          _measureTagChipWidth(context, tag, maxWidth),
        ),
      if (widget.isAddingTag)
        const _RecipeCreateTagSeed(
          _RecipeCreateTagItem.input(),
          _RecipeCreateTagInputChip.width,
        )
      else if (widget.tags.length < 10)
        _RecipeCreateTagSeed(
          const _RecipeCreateTagItem.add(),
          _measureAddTagChipWidth(context, maxWidth),
        ),
    ];
  }

  List<_RecipeCreateTagLayout> _justifyRow(
    List<_RecipeCreateTagSeed> row,
    double targetWidth,
  ) {
    final spacing = AppSpacing.xs * (row.length - 1);
    final baseWidth = row.fold<double>(0, (sum, seed) => sum + seed.width);
    final extra = (targetWidth - spacing - baseWidth).clamp(0, double.infinity);
    final extraPerChip = row.isEmpty ? 0.0 : extra / row.length;

    return [
      for (final seed in row)
        _RecipeCreateTagLayout(seed.item, seed.width + extraPerChip),
    ];
  }

  Widget _buildTagItem(_RecipeCreateTagItem item) {
    return switch (item.type) {
      _RecipeCreateTagItemType.tag => _RecipeCreateTagChip(
        tag: item.tag!,
        onRemove: () => widget.onRemoveTag(item.tag!),
      ),
      _RecipeCreateTagItemType.input => KeyedSubtree(
        key: _tagInputAnchorKey,
        child: _RecipeCreateTagInputChip(
          controller: widget.tagController,
          focusNode: widget.tagFocusNode,
          onSubmitted: widget.onSubmitTag,
          onCancel: widget.onCancelTagInput,
        ),
      ),
      _RecipeCreateTagItemType.add => _RecipeCreateAddTagChip(
        onPressed: widget.onAddTagPressed,
      ),
    };
  }

  double _rowWidth(List<_RecipeCreateTagSeed> row) {
    final spacing = AppSpacing.xs * (row.length - 1);
    return row.fold<double>(spacing, (sum, seed) => sum + seed.width);
  }

  double _measureTagChipWidth(
    BuildContext context,
    String tag,
    double maxWidth,
  ) {
    final textStyle =
        Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700) ??
        DefaultTextStyle.of(context).style;
    final textPainter = TextPainter(
      text: TextSpan(
        text: RecipeFormOptions.readableTagLabel(tag),
        style: textStyle,
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    return (textPainter.width + 24 + AppSpacing.xs + (AppSpacing.sm * 2))
        .clamp(58, maxWidth)
        .toDouble();
  }

  double _measureAddTagChipWidth(BuildContext context, double maxWidth) {
    final textStyle =
        Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800) ??
        DefaultTextStyle.of(context).style;
    final textPainter = TextPainter(
      text: TextSpan(text: 'Tag', style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    return (textPainter.width + 22 + AppSpacing.xxs + (AppSpacing.sm * 2))
        .clamp(58, maxWidth)
        .toDouble();
  }

  void _scheduleSuggestionsOverlaySync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncSuggestionsOverlay();
      }
    });
  }

  void _syncSuggestionsOverlay() {
    final shouldShow = widget.isAddingTag && widget.tagSuggestions.isNotEmpty;

    if (!shouldShow) {
      _removeSuggestionsOverlay();
      return;
    }

    if (_suggestionsOverlay == null) {
      _suggestionsOverlay = OverlayEntry(
        builder: (context) {
          final anchorRect = _tagInputRect;
          if (anchorRect == null) {
            return const SizedBox.shrink();
          }

          return Positioned(
            left: anchorRect.left,
            top: anchorRect.bottom + AppSpacing.xs,
            child: _RecipeCreateTagSuggestions(
              tags: widget.tagSuggestions,
              onSelected: widget.onSubmitTag,
            ),
          );
        },
      );
      Overlay.of(context, rootOverlay: true).insert(_suggestionsOverlay!);
      return;
    }

    _suggestionsOverlay?.markNeedsBuild();
  }

  Rect? get _tagInputRect {
    final renderObject = _tagInputAnchorKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }

    final offset = renderObject.localToGlobal(Offset.zero);
    return offset & renderObject.size;
  }

  void _removeSuggestionsOverlay() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }
}

enum _RecipeCreateTagItemType { tag, input, add }

class _RecipeCreateTagItem {
  const _RecipeCreateTagItem.tag(this.tag)
    : type = _RecipeCreateTagItemType.tag;

  const _RecipeCreateTagItem.input()
    : type = _RecipeCreateTagItemType.input,
      tag = null;

  const _RecipeCreateTagItem.add()
    : type = _RecipeCreateTagItemType.add,
      tag = null;

  final _RecipeCreateTagItemType type;
  final String? tag;
}

class _RecipeCreateTagSeed {
  const _RecipeCreateTagSeed(this.item, this.width);

  final _RecipeCreateTagItem item;
  final double width;
}

class _RecipeCreateTagLayout {
  const _RecipeCreateTagLayout(this.item, this.width);

  final _RecipeCreateTagItem item;
  final double width;
}

class _RecipeCreateTagChip extends StatelessWidget {
  const _RecipeCreateTagChip({required this.tag, required this.onRemove});

  final String tag;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              RecipeFormOptions.readableTagLabel(tag),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.mainText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          InkResponse(
            onTap: onRemove,
            radius: 14,
            child: Icon(Icons.remove_rounded, size: 16, color: palette.icons),
          ),
        ],
      ),
    );
  }
}

class _RecipeCreateTagSuggestions extends StatelessWidget {
  const _RecipeCreateTagSuggestions({
    required this.tags,
    required this.onSelected,
  });

  final List<String> tags;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: palette.navbarBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: palette.borders.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final tag in tags)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTapDown: (_) => onSelected(tag),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    RecipeFormOptions.readableTagLabel(tag),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.mainText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecipeCreateTagInputChip extends StatelessWidget {
  const _RecipeCreateTagInputChip({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onCancel,
  });

  static const double width = 180;

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      alignment: Alignment.center,
      width: width,
      padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.xs),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('recipe-create-tag-input'),
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 1,
              textInputAction: TextInputAction.done,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.mainText,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Tag',
                hintStyle: TextStyle(color: palette.secondaryText),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            tooltip: 'Cancel tag',
            onPressed: onCancel,
            icon: const Icon(Icons.remove_rounded),
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          ),
        ],
      ),
    );
  }
}

class _RecipeCreateAddTagChip extends StatelessWidget {
  const _RecipeCreateAddTagChip({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('recipe-create-add-tag-chip'),
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: palette.primaryButtons.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: palette.primaryButtons.withValues(alpha: 0.48),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 18, color: palette.mainText),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                'Tag',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.mainText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
