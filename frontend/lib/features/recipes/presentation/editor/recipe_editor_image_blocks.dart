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
