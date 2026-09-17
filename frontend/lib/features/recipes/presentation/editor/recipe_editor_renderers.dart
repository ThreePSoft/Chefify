part of '../pages/recipe_create_page.dart';

class _RecipeImageBlockContent extends StatelessWidget {
  const _RecipeImageBlockContent({
    required this.block,
    required this.onReplaceFirst,
  });

  final _RecipeEditorBlock block;
  final VoidCallback onReplaceFirst;

  @override
  Widget build(BuildContext context) {
    final alignment = switch (block.mediaAlignment) {
      _RecipeMediaAlignment.left => Alignment.centerLeft,
      _RecipeMediaAlignment.center => Alignment.center,
      _RecipeMediaAlignment.right => Alignment.centerRight,
    };
    final widthFactor = switch (block.mediaSize) {
      _RecipeMediaSize.extraSmall => 0.32,
      _RecipeMediaSize.small => 0.46,
      _RecipeMediaSize.medium => 0.62,
      _RecipeMediaSize.large => 0.8,
      _RecipeMediaSize.extraLarge => 1.0,
    };

    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: block.imageUrls.isEmpty
            ? _RecipeImagePlaceholder(
                onPressed: onReplaceFirst,
                aspectRatio: block.imageMode == _RecipeImageMode.collage
                    ? 2.4
                    : 16 / 9,
                label: block.imageMode == _RecipeImageMode.collage
                    ? 'Add first photo'
                    : 'Add photo',
                hoverLabel: block.imageMode == _RecipeImageMode.collage
                    ? 'Choose first photo'
                    : 'Choose photo',
              )
            : switch (block.imageMode) {
                _RecipeImageMode.single => _RecipeImagePreviewTile(
                  imageUrl: block.imageUrls.first,
                  onPressed: onReplaceFirst,
                ),
                _RecipeImageMode.collage => _RecipeCollagePreview(
                  imageUrls: block.imageUrls,
                  onPressed: onReplaceFirst,
                ),
                _RecipeImageMode.slider => _RecipeSliderPreview(
                  imageUrls: block.imageUrls,
                  autoplay: block.sliderAutoplay,
                  pace: block.sliderPace,
                  onPressed: onReplaceFirst,
                ),
              },
      ),
    );
  }
}

class _RecipeImagePlaceholder extends StatefulWidget {
  const _RecipeImagePlaceholder({
    required this.onPressed,
    required this.aspectRatio,
    required this.label,
    required this.hoverLabel,
  });

  final VoidCallback onPressed;
  final double aspectRatio;
  final String label;
  final String hoverLabel;

  @override
  State<_RecipeImagePlaceholder> createState() =>
      _RecipeImagePlaceholderState();
}

class _RecipeImagePlaceholderState extends State<_RecipeImagePlaceholder> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        key: const ValueKey('recipe-image-placeholder'),
        color: palette.searchBarBackground.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Column(
                key: ValueKey(_hovered),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 38,
                    color: palette.primaryButtons,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _hovered ? widget.hoverLabel : widget.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: palette.mainText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeImagePreviewTile extends StatefulWidget {
  const _RecipeImagePreviewTile({
    required this.imageUrl,
    required this.onPressed,
  });

  final String imageUrl;
  final VoidCallback onPressed;

  @override
  State<_RecipeImagePreviewTile> createState() =>
      _RecipeImagePreviewTileState();
}

class _RecipeImagePreviewTileState extends State<_RecipeImagePreviewTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onPressed,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _RecipeNetworkImage(imageUrl: widget.imageUrl),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  color: Colors.black.withValues(alpha: _hovered ? 0.48 : 0),
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _hovered ? 1 : 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: palette.mainText,
                          size: 28,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Replace photo',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: palette.mainText,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeCollagePreview extends StatelessWidget {
  const _RecipeCollagePreview({
    required this.imageUrls,
    required this.onPressed,
  });

  final List<String> imageUrls;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final visibleImages = imageUrls.take(5).toList(growable: false);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final rects = _layoutRects(size, visibleImages.length);

              return Stack(
                fit: StackFit.expand,
                children: [
                  for (var index = 0; index < visibleImages.length; index++)
                    Positioned.fromRect(
                      rect: rects[index],
                      child: SizedBox(
                        key: ValueKey('recipe-collage-image-$index'),
                        child: _RecipeNetworkImage(
                          imageUrl: visibleImages[index],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Rect> _layoutRects(Size size, int count) {
    const gap = 3.0;
    final width = size.width;
    final height = size.height;

    if (count <= 1) {
      return [Rect.fromLTWH(0, 0, width, height)];
    }
    if (count == 2) {
      final itemWidth = (width - gap) / 2;
      return [
        Rect.fromLTWH(0, 0, itemWidth, height),
        Rect.fromLTWH(itemWidth + gap, 0, itemWidth, height),
      ];
    }
    if (count == 3) {
      final mainWidth = (width - gap) * 0.62;
      final sideWidth = width - gap - mainWidth;
      final sideHeight = (height - gap) / 2;
      return [
        Rect.fromLTWH(0, 0, mainWidth, height),
        Rect.fromLTWH(mainWidth + gap, 0, sideWidth, sideHeight),
        Rect.fromLTWH(mainWidth + gap, sideHeight + gap, sideWidth, sideHeight),
      ];
    }
    if (count == 4) {
      final itemWidth = (width - gap) / 2;
      final itemHeight = (height - gap) / 2;
      return [
        Rect.fromLTWH(0, 0, itemWidth, itemHeight),
        Rect.fromLTWH(itemWidth + gap, 0, itemWidth, itemHeight),
        Rect.fromLTWH(0, itemHeight + gap, itemWidth, itemHeight),
        Rect.fromLTWH(itemWidth + gap, itemHeight + gap, itemWidth, itemHeight),
      ];
    }

    final mainWidth = (width - gap) * 0.4;
    final gridLeft = mainWidth + gap;
    final gridWidth = width - gridLeft;
    final itemWidth = (gridWidth - gap) / 2;
    final itemHeight = (height - gap) / 2;
    return [
      Rect.fromLTWH(0, 0, mainWidth, height),
      Rect.fromLTWH(gridLeft, 0, itemWidth, itemHeight),
      Rect.fromLTWH(gridLeft + itemWidth + gap, 0, itemWidth, itemHeight),
      Rect.fromLTWH(gridLeft, itemHeight + gap, itemWidth, itemHeight),
      Rect.fromLTWH(
        gridLeft + itemWidth + gap,
        itemHeight + gap,
        itemWidth,
        itemHeight,
      ),
    ];
  }
}

class _RecipeSliderPreview extends StatefulWidget {
  const _RecipeSliderPreview({
    required this.imageUrls,
    required this.autoplay,
    required this.pace,
    required this.onPressed,
  });

  final List<String> imageUrls;
  final bool autoplay;
  final _RecipeSliderPace pace;
  final VoidCallback onPressed;

  @override
  State<_RecipeSliderPreview> createState() => _RecipeSliderPreviewState();
}

class _RecipeSliderPreviewState extends State<_RecipeSliderPreview> {
  final PageController _pageController = PageController();
  Timer? _autoplayTimer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _syncAutoplay();
  }

  @override
  void didUpdateWidget(covariant _RecipeSliderPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoplay != widget.autoplay ||
        oldWidget.pace != widget.pace ||
        oldWidget.imageUrls.length != widget.imageUrls.length) {
      _page = _page.clamp(0, widget.imageUrls.length - 1);
      _syncAutoplay();
    }
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final imageUrls = widget.imageUrls.take(5).toList(growable: false);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              child: PageView.builder(
                controller: _pageController,
                itemCount: imageUrls.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) => InkWell(
                  onTap: widget.onPressed,
                  child: _RecipeNetworkImage(imageUrl: imageUrls[index]),
                ),
              ),
            ),
          ),
          if (imageUrls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.xs,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var index = 0; index < imageUrls.length; index++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: index == _page ? 18 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index == _page
                            ? palette.primaryButtons
                            : palette.mainText.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _syncAutoplay() {
    _autoplayTimer?.cancel();
    if (!widget.autoplay || widget.imageUrls.length < 2) {
      return;
    }
    final interval = switch (widget.pace) {
      _RecipeSliderPace.relaxed => const Duration(seconds: 8),
      _RecipeSliderPace.balanced => const Duration(seconds: 5),
      _RecipeSliderPace.quick => const Duration(seconds: 3),
    };
    _autoplayTimer = Timer.periodic(interval, (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      final nextPage = (_page + 1) % widget.imageUrls.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    });
  }
}

class _RecipeNetworkImage extends StatelessWidget {
  const _RecipeNetworkImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: palette.searchBarBackground,
        child: Icon(Icons.broken_image_outlined, color: palette.icons),
      ),
    );
  }
}

class _RecipeVideoBlockContent extends StatelessWidget {
  const _RecipeVideoBlockContent({
    required this.block,
    required this.onPressed,
  });

  final _RecipeEditorBlock block;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final alignment = switch (block.mediaAlignment) {
      _RecipeMediaAlignment.left => Alignment.centerLeft,
      _RecipeMediaAlignment.center => Alignment.center,
      _RecipeMediaAlignment.right => Alignment.centerRight,
    };
    final widthFactor = switch (block.mediaSize) {
      _RecipeMediaSize.extraSmall => 0.3,
      _RecipeMediaSize.small => 0.44,
      _RecipeMediaSize.medium => 0.6,
      _RecipeMediaSize.large => 0.78,
      _RecipeMediaSize.extraLarge => 1.0,
    };

    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: block.videoUrl.isEmpty
            ? _RecipeVideoPlaceholder(onPressed: onPressed)
            : _RecipeYoutubePreview(
                videoUrl: block.videoUrl,
                onPressed: onPressed,
              ),
      ),
    );
  }
}

class _RecipeVideoPlaceholder extends StatefulWidget {
  const _RecipeVideoPlaceholder({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_RecipeVideoPlaceholder> createState() =>
      _RecipeVideoPlaceholderState();
}

class _RecipeVideoPlaceholderState extends State<_RecipeVideoPlaceholder> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        key: const ValueKey('recipe-video-placeholder'),
        color: palette.searchBarBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: AspectRatio(
            aspectRatio: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: _hovered ? 1.08 : 1,
                  child: Icon(
                    Icons.add_rounded,
                    size: 48,
                    color: palette.primaryButtons,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _hovered ? 'Add YouTube link' : 'Video',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: palette.mainText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeYoutubePreview extends StatefulWidget {
  const _RecipeYoutubePreview({
    required this.videoUrl,
    required this.onPressed,
  });

  final String videoUrl;
  final VoidCallback onPressed;

  @override
  State<_RecipeYoutubePreview> createState() => _RecipeYoutubePreviewState();
}

class _RecipeYoutubePreviewState extends State<_RecipeYoutubePreview> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final videoId = _youtubeVideoId(widget.videoUrl);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        key: const ValueKey('recipe-youtube-preview'),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onPressed,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (videoId != null)
                  _RecipeNetworkImage(
                    imageUrl:
                        'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                  )
                else
                  ColoredBox(color: palette.searchBarBackground),
                ColoredBox(color: Colors.black.withValues(alpha: 0.28)),
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _hovered ? 62 : 56,
                    height: _hovered ? 62 : 56,
                    decoration: BoxDecoration(
                      color: palette.primaryButtons,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _hovered ? Icons.edit_rounded : Icons.play_arrow_rounded,
                      color: palette.mainText,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeYoutubeUrlDialog extends StatefulWidget {
  const _RecipeYoutubeUrlDialog({required this.initialUrl});

  final String initialUrl;

  @override
  State<_RecipeYoutubeUrlDialog> createState() =>
      _RecipeYoutubeUrlDialogState();
}

class _RecipeYoutubeUrlDialogState extends State<_RecipeYoutubeUrlDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AlertDialog(
      key: const ValueKey('recipe-youtube-url-dialog'),
      backgroundColor: palette.cardsSurface,
      title: const Text('YouTube video'),
      content: SizedBox(
        width: 480,
        child: TextField(
          key: const ValueKey('recipe-youtube-url-field'),
          controller: _controller,
          autofocus: true,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'YouTube URL',
            hintText: 'https://www.youtube.com/watch?v=...',
            errorText: _errorText,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Apply')),
      ],
    );
  }

  void _submit() {
    final value = _controller.text.trim();
    if (!_isYoutubeUrl(value)) {
      setState(() => _errorText = 'Enter a valid YouTube URL.');
      return;
    }
    Navigator.of(context).pop(value);
  }
}

class _RecipeDividerPreview extends StatelessWidget {
  const _RecipeDividerPreview({
    required this.style,
    required this.thickness,
    required this.color,
  });

  final _RecipeDividerStyle style;
  final _RecipeDividerThickness thickness;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('recipe-divider-preview'),
      height: 28,
      width: double.infinity,
      child: CustomPaint(
        painter: _RecipeDividerPainter(
          style: style,
          thickness: thickness,
          color: color,
        ),
      ),
    );
  }
}

class _RecipeDividerPainter extends CustomPainter {
  const _RecipeDividerPainter({
    required this.style,
    required this.thickness,
    required this.color,
  });

  final _RecipeDividerStyle style;
  final _RecipeDividerThickness thickness;
  final Color color;

  double get strokeWidth => switch (thickness) {
    _RecipeDividerThickness.thin => 1,
    _RecipeDividerThickness.regular => 2,
    _RecipeDividerThickness.bold => 4,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    switch (style) {
      case _RecipeDividerStyle.solid:
        canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), paint);
        break;
      case _RecipeDividerStyle.dotted:
        final spacing = math.max(5.0, strokeWidth * 3);
        for (var x = strokeWidth; x < size.width; x += spacing) {
          canvas.drawCircle(Offset(x, centerY), strokeWidth / 1.5, paint);
        }
        break;
      case _RecipeDividerStyle.dashed:
        _drawPattern(canvas, size.width, centerY, paint, const [12, 7]);
        break;
      case _RecipeDividerStyle.dashDot:
        _drawPattern(canvas, size.width, centerY, paint, const [14, 6, 2, 6]);
        break;
      case _RecipeDividerStyle.doubleLine:
        final offset = strokeWidth + 2;
        canvas
          ..drawLine(
            Offset(0, centerY - offset),
            Offset(size.width, centerY - offset),
            paint,
          )
          ..drawLine(
            Offset(0, centerY + offset),
            Offset(size.width, centerY + offset),
            paint,
          );
        break;
    }
  }

  void _drawPattern(
    Canvas canvas,
    double width,
    double y,
    Paint paint,
    List<double> pattern,
  ) {
    var x = 0.0;
    var patternIndex = 0;
    var drawing = true;
    while (x < width) {
      final segment = pattern[patternIndex % pattern.length];
      final end = math.min(width, x + segment);
      if (drawing) {
        canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      }
      x = end;
      patternIndex += 1;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant _RecipeDividerPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.thickness != thickness ||
        oldDelegate.color != color;
  }
}

class _RecipeBlockResizeHandle extends StatefulWidget {
  const _RecipeBlockResizeHandle({
    required this.blockId,
    required this.onResizeStart,
    required this.onResize,
    required this.onResizeEnd,
  });

  final String blockId;
  final VoidCallback onResizeStart;
  final ValueChanged<double> onResize;
  final VoidCallback onResizeEnd;

  @override
  State<_RecipeBlockResizeHandle> createState() =>
      _RecipeBlockResizeHandleState();
}

class _RecipeBlockResizeHandleState extends State<_RecipeBlockResizeHandle> {
  bool _hovered = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final active = _hovered || _dragging;

    return MouseRegion(
      key: ValueKey('recipe-editor-block-resize-${widget.blockId}'),
      cursor: SystemMouseCursors.resizeUpDown,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onVerticalDragStart: (_) {
          setState(() => _dragging = true);
          widget.onResizeStart();
        },
        onVerticalDragUpdate: (details) => widget.onResize(details.delta.dy),
        onVerticalDragEnd: (_) => _finishDrag(),
        onVerticalDragCancel: _finishDrag,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            width: active ? 72 : 42,
            height: 2,
            color: palette.primaryButtons.withValues(alpha: active ? 0.72 : 0),
          ),
        ),
      ),
    );
  }

  void _finishDrag() {
    if (_dragging) {
      setState(() => _dragging = false);
    }
    widget.onResizeEnd();
  }
}

class _RecipeBlockEdgeBorderPainter extends CustomPainter {
  const _RecipeBlockEdgeBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.18),
          color,
          color.withValues(alpha: 0.18),
        ],
      ).createShader(Offset.zero & size);
    final halfWidth = size.width / 2;

    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 0.55)
      ..quadraticBezierTo(halfWidth, 3.1, 0, 0.55)
      ..close();
    final bottomPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - 0.55)
      ..quadraticBezierTo(halfWidth, size.height - 3.1, 0, size.height - 0.55)
      ..close();

    canvas
      ..drawPath(topPath, paint)
      ..drawPath(bottomPath, paint);
  }

  @override
  bool shouldRepaint(covariant _RecipeBlockEdgeBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
