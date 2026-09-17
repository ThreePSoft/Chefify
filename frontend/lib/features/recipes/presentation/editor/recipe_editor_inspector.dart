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
                    label: 'Width',
                    values: _RecipeBlockWidth.values,
                    selected: selectedBlock.width,
                    labelForValue: _widthLabel,
                    onSelected: onWidthChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RecipePresetSelector<_RecipeBlockAlignment>(
                    label: 'Alignment',
                    values: _RecipeBlockAlignment.values,
                    selected: selectedBlock.alignment,
                    labelForValue: _alignmentLabel,
                    onSelected: onAlignmentChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RecipePresetSelector<_RecipeBlockSpacing>(
                    label: 'Spacing',
                    values: _RecipeBlockSpacing.values,
                    selected: selectedBlock.spacing,
                    labelForValue: _spacingLabel,
                    onSelected: onSpacingChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RecipePresetSelector<_RecipeBlockVariant>(
                    label: 'Variant',
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
            label: 'Block',
            icon: Icons.crop_free_rounded,
            selected: selected == _RecipeInspectorTab.block,
            onPressed: () => onSelected(_RecipeInspectorTab.block),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _RecipeInspectorTabButton(
            label: 'Content',
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

class _RecipeTextContentInspector extends StatelessWidget {
  const _RecipeTextContentInspector({
    required this.block,
    required this.onAlignmentChanged,
    required this.onSizeChanged,
    required this.onBlockChanged,
  });

  final _RecipeEditorBlock block;
  final ValueChanged<_RecipeTextAlignment> onAlignmentChanged;
  final ValueChanged<_RecipeTextSize> onSizeChanged;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (block.kind == _RecipeBlockKind.image) {
      return _RecipeImageContentInspector(
        block: block,
        onBlockChanged: onBlockChanged,
      );
    }
    if (block.kind == _RecipeBlockKind.video) {
      return _RecipeVideoContentInspector(
        block: block,
        onBlockChanged: onBlockChanged,
      );
    }
    if (block.kind == _RecipeBlockKind.note) {
      return _RecipeNoteContentInspector(
        block: block,
        onBlockChanged: onBlockChanged,
      );
    }
    if (block.kind == _RecipeBlockKind.divider) {
      return _RecipeDividerContentInspector(
        block: block,
        onBlockChanged: onBlockChanged,
      );
    }
    if (!block.kind.supportsTextSettings) {
      return Text(
        'This block has no content presets yet.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
      );
    }

    final alignments = block.kind.supportsJustifiedText
        ? _RecipeTextAlignment.values
        : _RecipeTextAlignment.values
              .where((value) => value != _RecipeTextAlignment.justify)
              .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text alignment',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (var index = 0; index < alignments.length; index++) ...[
              Expanded(
                child: _RecipeTextAlignmentButton(
                  alignment: alignments[index],
                  selected: block.textAlignment == alignments[index],
                  onPressed: () => onAlignmentChanged(alignments[index]),
                ),
              ),
              if (index < alignments.length - 1)
                const SizedBox(width: AppSpacing.xs),
            ],
          ],
        ),
        if (block.kind == _RecipeBlockKind.quote) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Quote line',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: palette.categoryTags,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (final side in _RecipeQuoteLineSide.values) ...[
                Expanded(
                  child: _RecipeQuoteLineSideButton(
                    side: side,
                    selected: block.quoteLineSide == side,
                    onPressed: () =>
                        onBlockChanged(block.copyWith(quoteLineSide: side)),
                  ),
                ),
                if (side != _RecipeQuoteLineSide.values.last)
                  const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          'Text size',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<_RecipeTextSize>(
          key: ValueKey('recipe-text-size-${block.id}-${block.textSize.name}'),
          initialValue: block.textSize,
          isExpanded: true,
          dropdownColor: palette.navbarBackground,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: palette.searchBarBackground.withValues(alpha: 0.72),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              borderSide: BorderSide(
                color: palette.borders.withValues(alpha: 0.72),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              borderSide: BorderSide(
                color: palette.borders.withValues(alpha: 0.72),
              ),
            ),
          ),
          items: [
            for (final size in _RecipeTextSize.values)
              DropdownMenuItem(value: size, child: Text(_textSizeLabel(size))),
          ],
          onChanged: (value) {
            if (value != null) {
              onSizeChanged(value);
            }
          },
        ),
      ],
    );
  }

  String _textSizeLabel(_RecipeTextSize size) {
    return switch (size) {
      _RecipeTextSize.extraSmall => 'Extra small',
      _RecipeTextSize.small => 'Small',
      _RecipeTextSize.medium => 'Medium',
      _RecipeTextSize.large => 'Large',
      _RecipeTextSize.extraLarge => 'Extra large',
    };
  }
}

class _RecipeNoteContentInspector extends StatelessWidget {
  const _RecipeNoteContentInspector({
    required this.block,
    required this.onBlockChanged,
  });

  final _RecipeEditorBlock block;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final alignments = _RecipeTextAlignment.values
        .where((alignment) => alignment != _RecipeTextAlignment.justify)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeInspectorDropdown<_RecipeNoteTone>(
          controlKey: 'recipe-note-tone-${block.noteTone.name}',
          label: 'Note style',
          value: block.noteTone,
          values: _RecipeNoteTone.values,
          labelForValue: (tone) => switch (tone) {
            _RecipeNoteTone.tip => 'Tip',
            _RecipeNoteTone.info => 'Information',
            _RecipeNoteTone.warning => 'Warning',
            _RecipeNoteTone.important => 'Important',
          },
          onChanged: (tone) => onBlockChanged(block.copyWith(noteTone: tone)),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Text alignment',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (var index = 0; index < alignments.length; index++) ...[
              Expanded(
                child: _RecipeTextAlignmentButton(
                  alignment: alignments[index],
                  selected: block.textAlignment == alignments[index],
                  onPressed: () => onBlockChanged(
                    block.copyWith(textAlignment: alignments[index]),
                  ),
                ),
              ),
              if (index < alignments.length - 1)
                const SizedBox(width: AppSpacing.xs),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _RecipeInspectorDropdown<_RecipeTextSize>(
          controlKey: 'recipe-note-size-${block.textSize.name}',
          label: 'Text size',
          value: block.textSize,
          values: _RecipeTextSize.values,
          labelForValue: (size) => switch (size) {
            _RecipeTextSize.extraSmall => 'Extra small',
            _RecipeTextSize.small => 'Small',
            _RecipeTextSize.medium => 'Medium',
            _RecipeTextSize.large => 'Large',
            _RecipeTextSize.extraLarge => 'Extra large',
          },
          onChanged: (size) => onBlockChanged(block.copyWith(textSize: size)),
        ),
      ],
    );
  }
}

class _RecipeDividerContentInspector extends StatelessWidget {
  const _RecipeDividerContentInspector({
    required this.block,
    required this.onBlockChanged,
  });

  final _RecipeEditorBlock block;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = _recipeDividerColors(palette);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeInspectorDropdown<_RecipeDividerStyle>(
          controlKey: 'recipe-divider-style-${block.dividerStyle.name}',
          label: 'Line style',
          value: block.dividerStyle,
          values: _RecipeDividerStyle.values,
          labelForValue: (style) => switch (style) {
            _RecipeDividerStyle.solid => 'Solid',
            _RecipeDividerStyle.dotted => 'Dotted',
            _RecipeDividerStyle.dashed => 'Dashed',
            _RecipeDividerStyle.dashDot => 'Dash-dot',
            _RecipeDividerStyle.doubleLine => 'Double solid',
          },
          onChanged: (style) =>
              onBlockChanged(block.copyWith(dividerStyle: style)),
        ),
        const SizedBox(height: AppSpacing.md),
        _RecipeInspectorDropdown<_RecipeDividerThickness>(
          controlKey: 'recipe-divider-thickness-${block.dividerThickness.name}',
          label: 'Thickness',
          value: block.dividerThickness,
          values: _RecipeDividerThickness.values,
          labelForValue: (thickness) => switch (thickness) {
            _RecipeDividerThickness.thin => 'Thin',
            _RecipeDividerThickness.regular => 'Regular',
            _RecipeDividerThickness.bold => 'Bold',
          },
          onChanged: (thickness) =>
              onBlockChanged(block.copyWith(dividerThickness: thickness)),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Color',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (var index = 0; index < colors.length; index++) ...[
              _RecipeDividerColorSwatch(
                index: index,
                color: colors[index],
                selected: block.dividerColorIndex == index,
                onPressed: () =>
                    onBlockChanged(block.copyWith(dividerColorIndex: index)),
              ),
              if (index < colors.length - 1)
                const SizedBox(width: AppSpacing.xs),
            ],
          ],
        ),
      ],
    );
  }
}

class _RecipeDividerColorSwatch extends StatelessWidget {
  const _RecipeDividerColorSwatch({
    required this.index,
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  final int index;
  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: 'Color ${index + 1}',
      child: InkWell(
        key: ValueKey('recipe-divider-color-$index'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.xxs),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.xxs),
            border: Border.all(
              color: selected ? palette.primaryButtons : palette.borders,
              width: selected ? 3 : 1,
            ),
          ),
          child: selected
              ? Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: palette.pageBackground,
                )
              : null,
        ),
      ),
    );
  }
}

class _RecipeVideoContentInspector extends StatelessWidget {
  const _RecipeVideoContentInspector({
    required this.block,
    required this.onBlockChanged,
  });

  final _RecipeEditorBlock block;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final invalidUrl =
        block.videoUrl.isNotEmpty && !_isYoutubeUrl(block.videoUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeMediaAlignmentSelector(
          selected: block.mediaAlignment,
          onChanged: (alignment) =>
              onBlockChanged(block.copyWith(mediaAlignment: alignment)),
        ),
        const SizedBox(height: AppSpacing.md),
        _RecipeInspectorDropdown<_RecipeMediaSize>(
          controlKey: 'recipe-video-size-${block.mediaSize.name}',
          label: 'Video size',
          value: block.mediaSize,
          values: _RecipeMediaSize.values,
          labelForValue: _mediaSizeLabel,
          onChanged: (size) => onBlockChanged(block.copyWith(mediaSize: size)),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'YouTube URL',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          key: const ValueKey('recipe-video-url-inspector-field'),
          initialValue: block.videoUrl,
          onChanged: (value) =>
              onBlockChanged(block.copyWith(videoUrl: value.trim())),
          decoration: InputDecoration(
            hintText: 'https://www.youtube.com/watch?v=...',
            errorText: invalidUrl ? 'Use a valid YouTube link.' : null,
          ),
        ),
      ],
    );
  }

  String _mediaSizeLabel(_RecipeMediaSize size) {
    return switch (size) {
      _RecipeMediaSize.extraSmall => 'Extra small',
      _RecipeMediaSize.small => 'Small',
      _RecipeMediaSize.medium => 'Medium',
      _RecipeMediaSize.large => 'Large',
      _RecipeMediaSize.extraLarge => 'Extra large',
    };
  }
}

class _RecipeImageContentInspector extends StatelessWidget {
  const _RecipeImageContentInspector({
    required this.block,
    required this.onBlockChanged,
  });

  final _RecipeEditorBlock block;
  final ValueChanged<_RecipeEditorBlock> onBlockChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final maxImages = block.imageMode == _RecipeImageMode.single ? 1 : 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeInspectorDropdown<_RecipeImageMode>(
          controlKey: 'recipe-image-mode-${block.imageMode.name}',
          label: 'Image mode',
          value: block.imageMode,
          values: _RecipeImageMode.values,
          labelForValue: _imageModeLabel,
          onChanged: (mode) {
            final imageUrls =
                mode == _RecipeImageMode.single && block.imageUrls.isNotEmpty
                ? [block.imageUrls.first]
                : block.imageUrls;
            onBlockChanged(
              block.copyWith(imageMode: mode, imageUrls: imageUrls),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _RecipeMediaAlignmentSelector(
          selected: block.mediaAlignment,
          onChanged: (alignment) =>
              onBlockChanged(block.copyWith(mediaAlignment: alignment)),
        ),
        const SizedBox(height: AppSpacing.md),
        _RecipeInspectorDropdown<_RecipeMediaSize>(
          controlKey: 'recipe-media-size-${block.mediaSize.name}',
          label: 'Media size',
          value: block.mediaSize,
          values: _RecipeMediaSize.values,
          labelForValue: _mediaSizeLabel,
          onChanged: (size) => onBlockChanged(block.copyWith(mediaSize: size)),
        ),
        if (block.imageMode == _RecipeImageMode.slider) ...[
          const SizedBox(height: AppSpacing.md),
          Material(
            color: Colors.transparent,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Autoplay',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.mainText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              value: block.sliderAutoplay,
              onChanged: (value) =>
                  onBlockChanged(block.copyWith(sliderAutoplay: value)),
            ),
          ),
          if (block.sliderAutoplay) ...[
            const SizedBox(height: AppSpacing.xs),
            _RecipeInspectorDropdown<_RecipeSliderPace>(
              controlKey: 'recipe-slider-pace-${block.sliderPace.name}',
              label: 'Autoplay pace',
              value: block.sliderPace,
              values: _RecipeSliderPace.values,
              labelForValue: _sliderPaceLabel,
              onChanged: (pace) =>
                  onBlockChanged(block.copyWith(sliderPace: pace)),
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          'Photos',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var index = 0; index < block.imageUrls.length; index++) ...[
          _RecipeInspectorImageRow(
            index: index,
            imageUrl: block.imageUrls[index],
            onReplace: () => _pickImage(replaceIndex: index),
            onDelete: () => _deleteImage(index),
          ),
          if (index < block.imageUrls.length - 1)
            const SizedBox(height: AppSpacing.xs),
        ],
        if (block.imageUrls.length < maxImages) ...[
          if (block.imageUrls.isNotEmpty) const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const ValueKey('recipe-image-add-from-inspector'),
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                block.imageUrls.isEmpty ? 'Upload photo' : 'Add photo',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage({int? replaceIndex}) async {
    final imageUrl = await pickRecipeHeroImageUrl();
    if (imageUrl == null) {
      return;
    }
    final imageUrls = [...block.imageUrls];
    if (replaceIndex != null && replaceIndex < imageUrls.length) {
      imageUrls[replaceIndex] = imageUrl;
    } else if (imageUrls.length < 5) {
      imageUrls.add(imageUrl);
    }
    onBlockChanged(block.copyWith(imageUrls: imageUrls));
  }

  void _deleteImage(int index) {
    final imageUrls = [...block.imageUrls]..removeAt(index);
    onBlockChanged(block.copyWith(imageUrls: imageUrls));
  }

  String _imageModeLabel(_RecipeImageMode mode) {
    return switch (mode) {
      _RecipeImageMode.single => 'Single photo',
      _RecipeImageMode.collage => 'Collage',
      _RecipeImageMode.slider => 'Slider',
    };
  }

  String _mediaSizeLabel(_RecipeMediaSize size) {
    return switch (size) {
      _RecipeMediaSize.extraSmall => 'Extra small',
      _RecipeMediaSize.small => 'Small',
      _RecipeMediaSize.medium => 'Medium',
      _RecipeMediaSize.large => 'Large',
      _RecipeMediaSize.extraLarge => 'Extra large',
    };
  }

  String _sliderPaceLabel(_RecipeSliderPace pace) {
    return switch (pace) {
      _RecipeSliderPace.relaxed => 'Relaxed',
      _RecipeSliderPace.balanced => 'Balanced',
      _RecipeSliderPace.quick => 'Quick',
    };
  }
}

class _RecipeInspectorImageRow extends StatelessWidget {
  const _RecipeInspectorImageRow({
    required this.index,
    required this.imageUrl,
    required this.onReplace,
    required this.onDelete,
  });

  final int index;
  final String imageUrl;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.xxs),
            child: SizedBox(
              width: 44,
              height: 36,
              child: _RecipeNetworkImage(imageUrl: imageUrl),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Photo ${index + 1}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.mainText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Replace photo ${index + 1}',
            onPressed: onReplace,
            icon: const Icon(Icons.refresh_rounded),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Delete photo ${index + 1}',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _RecipeMediaAlignmentSelector extends StatelessWidget {
  const _RecipeMediaAlignmentSelector({
    required this.selected,
    required this.onChanged,
  });

  final _RecipeMediaAlignment selected;
  final ValueChanged<_RecipeMediaAlignment> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alignment',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.categoryTags,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (final alignment in _RecipeMediaAlignment.values) ...[
              Expanded(
                child: _RecipeMediaAlignmentButton(
                  alignment: alignment,
                  selected: selected == alignment,
                  onPressed: () => onChanged(alignment),
                ),
              ),
              if (alignment != _RecipeMediaAlignment.values.last)
                const SizedBox(width: AppSpacing.xs),
            ],
          ],
        ),
      ],
    );
  }
}

class _RecipeMediaAlignmentButton extends StatelessWidget {
  const _RecipeMediaAlignmentButton({
    required this.alignment,
    required this.selected,
    required this.onPressed,
  });

  final _RecipeMediaAlignment alignment;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (icon, label) = switch (alignment) {
      _RecipeMediaAlignment.left => (
        Icons.align_horizontal_left_rounded,
        'Left',
      ),
      _RecipeMediaAlignment.center => (
        Icons.align_horizontal_center_rounded,
        'Center',
      ),
      _RecipeMediaAlignment.right => (
        Icons.align_horizontal_right_rounded,
        'Right',
      ),
    };

    return Tooltip(
      message: label,
      child: Material(
        key: ValueKey('recipe-media-align-${alignment.name}'),
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
