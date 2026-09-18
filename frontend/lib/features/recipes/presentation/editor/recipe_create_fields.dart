part of '../pages/recipe_create_page.dart';

class _RecipeHeroTextField extends StatefulWidget {
  const _RecipeHeroTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.style,
    required this.minLines,
    required this.maxLines,
  });

  final TextEditingController controller;
  final String hintText;
  final TextStyle? style;
  final int minLines;
  final int maxLines;

  @override
  State<_RecipeHeroTextField> createState() => _RecipeHeroTextFieldState();
}

class _RecipeHeroTextFieldState extends State<_RecipeHeroTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFieldStateChange);
    widget.controller.addListener(_handleFieldStateChange);
  }

  @override
  void didUpdateWidget(covariant _RecipeHeroTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleFieldStateChange);
      widget.controller.addListener(_handleFieldStateChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleFieldStateChange);
    _focusNode.removeListener(_handleFieldStateChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasText = widget.controller.text.trim().isNotEmpty;
    final isPlainText = hasText && !_focusNode.hasFocus;

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      style: widget.style,
      cursorColor: palette.primaryButtons,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.style?.copyWith(
          color: palette.mainText.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: isPlainText
            ? Colors.transparent
            : palette.searchBarBackground.withValues(alpha: 0.42),
        border: _fieldBorder(palette, isPlainText: isPlainText),
        enabledBorder: _fieldBorder(palette, isPlainText: isPlainText),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: palette.primaryButtons.withValues(alpha: 0.72),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }

  void _handleFieldStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  OutlineInputBorder _fieldBorder(
    AppPalette palette, {
    required bool isPlainText,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(
        color: isPlainText
            ? Colors.transparent
            : palette.borders.withValues(alpha: 0.36),
      ),
    );
  }
}

class _RecipeCreateImageDropZone extends StatelessWidget {
  const _RecipeCreateImageDropZone({
    required this.imageUrl,
    required this.onPressed,
  });

  final String? imageUrl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selectedImageUrl = imageUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (selectedImageUrl == null)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette.searchBarBackground.withValues(alpha: 0.9),
                      palette.cardsSurface.withValues(alpha: 0.72),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              )
            else
              Image.network(selectedImageUrl, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}

class _RecipeCreateUploadHint extends StatelessWidget {
  const _RecipeCreateUploadHint({
    required this.imageUrl,
    required this.isImageHovered,
  });

  final String? imageUrl;
  final bool isImageHovered;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasImage = imageUrl != null;
    final isVisible = !hasImage || isImageHovered;

    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: hasImage
                ? palette.navbarBackground.withValues(alpha: 0.72)
                : palette.primaryButtons.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: palette.primaryButtons.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(Icons.add_rounded, size: 52, color: palette.mainText),
        ),
      ),
    );
  }
}

class _RecipeCreateHeroGradientOverlay extends StatelessWidget {
  const _RecipeCreateHeroGradientOverlay({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: compact ? Alignment.topCenter : Alignment.centerLeft,
          end: compact ? Alignment.bottomCenter : Alignment.centerRight,
          colors: [
            Colors.black.withValues(alpha: compact ? 0.16 : 0.1),
            palette.navbarBackground.withValues(alpha: compact ? 0.66 : 0.48),
            palette.navbarBackground.withValues(alpha: compact ? 0.96 : 0.9),
          ],
          stops: compact ? const [0, 0.46, 1] : const [0, 0.55, 1],
        ),
      ),
    );
  }
}

class _RecipeCreateHeaderShell extends StatelessWidget {
  const _RecipeCreateHeaderShell({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.navbarBackground.withValues(alpha: 0.94),
          border: Border(
            bottom: BorderSide(color: palette.borders.withValues(alpha: 0.5)),
          ),
        ),
        child: child,
      ),
    );
  }
}
