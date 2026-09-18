part of '../pages/recipe_create_page.dart';

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
