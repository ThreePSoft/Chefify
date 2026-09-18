part of '../pages/recipe_create_page.dart';

class _RecipeCreateHeroPanel extends StatefulWidget {
  const _RecipeCreateHeroPanel({
    required this.imageUrl,
    required this.titleController,
    required this.descriptionController,
    required this.tags,
    required this.isAddingTag,
    required this.tagController,
    required this.tagFocusNode,
    required this.tagSuggestions,
    required this.duration,
    required this.difficulty,
    required this.category,
    required this.onEditDuration,
    required this.onEditDifficulty,
    required this.onEditCategory,
    required this.onSubmitTag,
    required this.onRemoveTag,
    required this.onAddTagPressed,
    required this.onCancelTagInput,
    required this.onPickImage,
  });

  static const double _desktopHeight = 400;
  static const double _compactHeight = 720;

  final String? imageUrl;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<String> tags;
  final bool isAddingTag;
  final TextEditingController tagController;
  final FocusNode tagFocusNode;
  final List<String> tagSuggestions;
  final _RecipeDurationValue duration;
  final String difficulty;
  final CategoryModel? category;
  final VoidCallback onEditDuration;
  final VoidCallback onEditDifficulty;
  final VoidCallback onEditCategory;
  final ValueChanged<String> onSubmitTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onAddTagPressed;
  final VoidCallback onCancelTagInput;
  final VoidCallback onPickImage;

  @override
  State<_RecipeCreateHeroPanel> createState() => _RecipeCreateHeroPanelState();
}

class _RecipeCreateHeroPanelState extends State<_RecipeCreateHeroPanel> {
  Timer? _imageHoverTimer;
  bool _isImageHovered = false;

  @override
  void dispose() {
    _imageHoverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      padding: EdgeInsets.zero,
      radius: AppSpacing.radiusLg,
      backgroundColor: palette.navbarBackground,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;

            return SizedBox(
              height: compact
                  ? _RecipeCreateHeroPanel._compactHeight
                  : _RecipeCreateHeroPanel._desktopHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => _setImageHovered(true),
                    onExit: (_) => _setImageHovered(false),
                    child: _RecipeCreateImageDropZone(
                      imageUrl: widget.imageUrl,
                      onPressed: widget.onPickImage,
                    ),
                  ),
                  IgnorePointer(
                    child: _RecipeCreateHeroGradientOverlay(compact: compact),
                  ),
                  IgnorePointer(
                    child: _RecipeCreateUploadHint(
                      imageUrl: widget.imageUrl,
                      isImageHovered: _isImageHovered,
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(
                        compact ? AppSpacing.lg : AppSpacing.xl,
                      ),
                      child: _RecipeCreateHeroEditor(
                        titleController: widget.titleController,
                        descriptionController: widget.descriptionController,
                        tags: widget.tags,
                        isAddingTag: widget.isAddingTag,
                        tagController: widget.tagController,
                        tagFocusNode: widget.tagFocusNode,
                        tagSuggestions: widget.tagSuggestions,
                        duration: widget.duration,
                        difficulty: widget.difficulty,
                        category: widget.category,
                        onEditDuration: widget.onEditDuration,
                        onEditDifficulty: widget.onEditDifficulty,
                        onEditCategory: widget.onEditCategory,
                        onSubmitTag: widget.onSubmitTag,
                        onRemoveTag: widget.onRemoveTag,
                        onAddTagPressed: widget.onAddTagPressed,
                        onCancelTagInput: widget.onCancelTagInput,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _setImageHovered(bool isHovered) {
    _imageHoverTimer?.cancel();

    if (isHovered) {
      _imageHoverTimer = Timer(const Duration(milliseconds: 180), () {
        if (!mounted || _isImageHovered) {
          return;
        }

        setState(() {
          _isImageHovered = true;
        });
      });
    } else if (_isImageHovered) {
      setState(() {
        _isImageHovered = false;
      });
    }
  }
}

class _RecipeCreateHeroEditor extends StatelessWidget {
  const _RecipeCreateHeroEditor({
    required this.titleController,
    required this.descriptionController,
    required this.tags,
    required this.isAddingTag,
    required this.tagController,
    required this.tagFocusNode,
    required this.tagSuggestions,
    required this.duration,
    required this.difficulty,
    required this.category,
    required this.onEditDuration,
    required this.onEditDifficulty,
    required this.onEditCategory,
    required this.onSubmitTag,
    required this.onRemoveTag,
    required this.onAddTagPressed,
    required this.onCancelTagInput,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<String> tags;
  final bool isAddingTag;
  final TextEditingController tagController;
  final FocusNode tagFocusNode;
  final List<String> tagSuggestions;
  final _RecipeDurationValue duration;
  final String difficulty;
  final CategoryModel? category;
  final VoidCallback onEditDuration;
  final VoidCallback onEditDifficulty;
  final VoidCallback onEditCategory;
  final ValueChanged<String> onSubmitTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onAddTagPressed;
  final VoidCallback onCancelTagInput;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final editorWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth * 0.54).clamp(440.0, 640.0).toDouble();

        return Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: editorWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RecipeHeroTextField(
                      key: const ValueKey('recipe-create-title-field'),
                      controller: titleController,
                      hintText: strings.recipeTitle,
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontSize: compact ? 34 : 46),
                      minLines: 1,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _RecipeHeroTextField(
                      key: const ValueKey('recipe-create-description-field'),
                      controller: descriptionController,
                      hintText: strings.recipeDescription,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: compact ? 16 : 18,
                        height: 1.45,
                      ),
                      minLines: 2,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: compact ? 156 : 0,
              right: compact ? 0 : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: editorWidth),
                child: _RecipeCreateTagRow(
                  tags: tags,
                  isAddingTag: isAddingTag,
                  tagController: tagController,
                  tagFocusNode: tagFocusNode,
                  tagSuggestions: tagSuggestions,
                  onSubmitTag: onSubmitTag,
                  onRemoveTag: onRemoveTag,
                  onAddTagPressed: onAddTagPressed,
                  onCancelTagInput: onCancelTagInput,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: _RecipeCreateMetaPanel(
                duration: duration,
                difficulty: difficulty,
                category: category,
                onEditDuration: onEditDuration,
                onEditDifficulty: onEditDifficulty,
                onEditCategory: onEditCategory,
              ),
            ),
          ],
        );
      },
    );
  }
}
