import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/recipes/data/recipe_form_options.dart';
import 'package:frontend/features/recipes/presentation/image_upload/recipe_image_picker.dart';
import 'package:frontend/shared/models/home_models.dart';

part '../editor/recipe_body_editor.dart';
part '../editor/recipe_editor_definitions.dart';
part '../editor/recipe_editor_drag_drop.dart';
part '../editor/recipe_editor_models.dart';
part '../editor/recipe_create_dialogs.dart';
part '../editor/recipe_create_fields.dart';
part '../editor/recipe_create_hero.dart';
part '../editor/recipe_create_meta.dart';
part '../editor/recipe_create_tags.dart';
part '../editor/recipe_editor_block_surface.dart';
part '../editor/recipe_editor_canvas_layout.dart';
part '../editor/recipe_editor_drop_zones.dart';
part '../editor/recipe_editor_compact_palette.dart';
part '../editor/recipe_editor_overlay.dart';
part '../editor/recipe_editor_inspector_content.dart';
part '../editor/recipe_editor_inspector_controls.dart';
part '../editor/recipe_editor_inspector_shell.dart';
part '../editor/recipe_editor_palette.dart';
part '../editor/recipe_editor_block_decorations.dart';
part '../editor/recipe_editor_image_blocks.dart';
part '../editor/recipe_editor_video_blocks.dart';

const double _recipeAuthorCardExtent = 224;
const double _recipeAuthorCardOffset = -60;
const double _recipeAuthorCardAngle = -0.2;

String? _youtubeVideoId(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
    return null;
  }
  final host = uri.host.toLowerCase().replaceFirst('www.', '');
  if (host == 'youtu.be') {
    return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
  }
  if (host != 'youtube.com' && host != 'm.youtube.com') {
    return null;
  }
  final queryId = uri.queryParameters['v'];
  if (queryId != null && queryId.isNotEmpty) {
    return queryId;
  }
  if (uri.pathSegments.length >= 2 &&
      (uri.pathSegments.first == 'embed' ||
          uri.pathSegments.first == 'shorts')) {
    return uri.pathSegments[1];
  }
  return null;
}

bool _isYoutubeUrl(String value) => _youtubeVideoId(value) != null;

List<Color> _recipeDividerColors(AppPalette palette) => [
  palette.primaryButtons,
  palette.categoryTags,
  palette.mainText,
  palette.secondaryText,
  const Color(0xFFD85A5A),
];

@immutable
class _RecipeDurationValue {
  const _RecipeDurationValue({
    required this.days,
    required this.hours,
    required this.minutes,
  });

  final int days;
  final int hours;
  final int minutes;

  _RecipeDurationValue copyWith({int? days, int? hours, int? minutes}) {
    return _RecipeDurationValue(
      days: days ?? this.days,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
    );
  }

  String get label {
    final parts = <String>[];
    if (days > 0) {
      parts.add('${days}d');
    }
    if (hours > 0) {
      parts.add('${hours}h');
    }
    if (minutes > 0 || parts.isEmpty) {
      parts.add('$minutes min');
    }
    return parts.join(' ');
  }
}

class RecipeCreatePage extends StatefulWidget {
  const RecipeCreatePage({super.key});

  @override
  State<RecipeCreatePage> createState() => _RecipeCreatePageState();
}

class _RecipeCreatePageState extends State<RecipeCreatePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _tagFocusNode = FocusNode();
  final List<String> _tags = [];
  _RecipeDurationValue _duration = const _RecipeDurationValue(
    days: 0,
    hours: 0,
    minutes: 20,
  );
  String _difficulty = 'Easy';
  CategoryModel? _category;
  bool _isAddingTag = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _tagFocusNode.addListener(_handleTagFocusChange);
    _tagController.addListener(_handleTagTextChange);
  }

  @override
  void dispose() {
    releaseRecipeImageUrl(_imageUrl);
    _tagFocusNode.removeListener(_handleTagFocusChange);
    _tagController.removeListener(_handleTagTextChange);
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _tagFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);

    return Scaffold(
      key: const ValueKey('recipe-create-page'),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.pageBackground, palette.cardsSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.horizontalPaddingForWidth(viewportWidth),
                    headerHeight + AppSpacing.xl,
                    AppSpacing.horizontalPaddingForWidth(viewportWidth),
                    AppSpacing.sectionGapForWidth(viewportWidth),
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSpacing.contentMaxWidth,
                        ),
                        child: _RecipeCreateContent(
                          scrollController: _scrollController,
                          imageUrl: _imageUrl,
                          titleController: _titleController,
                          descriptionController: _descriptionController,
                          tags: _tags,
                          isAddingTag: _isAddingTag,
                          tagController: _tagController,
                          tagFocusNode: _tagFocusNode,
                          tagSuggestions: _tagSuggestions,
                          duration: _duration,
                          difficulty: _difficulty,
                          category: _category,
                          onEditDuration: _editDuration,
                          onEditDifficulty: _editDifficulty,
                          onEditCategory: _editCategory,
                          onSubmitTag: _submitTag,
                          onRemoveTag: _removeTag,
                          onAddTagPressed: _startAddingTag,
                          onCancelTagInput: _cancelTagInput,
                          onPickImage: _pickImage,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _RecipeCreateHeaderShell(
              height: headerHeight,
              child: const AppHeader(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final imageUrl = await pickRecipeHeroImageUrl();
    if (imageUrl == null) {
      return;
    }
    if (!mounted) {
      releaseRecipeImageUrl(imageUrl);
      return;
    }

    final previousImageUrl = _imageUrl;
    setState(() {
      _imageUrl = imageUrl;
    });
    releaseRecipeImageUrl(previousImageUrl);
  }

  void _handleTagFocusChange() {
    if (!_tagFocusNode.hasFocus && _isAddingTag) {
      _submitTag(_tagController.text);
    }
  }

  void _handleTagTextChange() {
    if (_isAddingTag) {
      setState(() {});
    }
  }

  void _startAddingTag() {
    if (_tags.length >= 10) {
      return;
    }

    setState(() {
      _isAddingTag = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _tagFocusNode.requestFocus();
      }
    });
  }

  void _submitTag(String value) {
    final slug = RecipeFormOptions.slug(value);
    if (slug.isEmpty) {
      _cancelTagInput();
      return;
    }

    setState(() {
      if (!_tags.contains(slug) && _tags.length < 10) {
        _tags.add(slug);
      }
      _isAddingTag = false;
    });
    _tagController.clear();
  }

  void _cancelTagInput() {
    setState(() {
      _isAddingTag = false;
    });
    _tagController.clear();
  }

  Future<void> _editDuration() async {
    final value = await showDialog<_RecipeDurationValue>(
      context: context,
      builder: (context) => _RecipeDurationPickerDialog(initial: _duration),
    );
    if (!mounted || value == null) {
      return;
    }

    setState(() {
      _duration = value;
    });
  }

  Future<void> _editDifficulty() async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => _RecipeDifficultyDialog(selected: _difficulty),
    );
    if (!mounted || value == null) {
      return;
    }

    setState(() {
      _difficulty = value;
    });
  }

  Future<void> _editCategory() async {
    final value = await showDialog<CategoryModel>(
      context: context,
      builder: (context) => _RecipeCategoryDialog(selected: _category),
    );
    if (!mounted || value == null) {
      return;
    }

    setState(() {
      _category = value;
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  List<String> get _tagSuggestions {
    if (!_isAddingTag) {
      return const [];
    }

    final query = RecipeFormOptions.slug(_tagController.text);
    final suggestions = RecipeFormOptions.availableTags
        .where((tag) {
          if (_tags.contains(tag)) {
            return false;
          }

          if (query.isEmpty) {
            return true;
          }

          final label = RecipeFormOptions.readableTagLabel(tag).toLowerCase();
          return tag.contains(query) ||
              label.contains(query.replaceAll('-', ' '));
        })
        .take(6);

    return suggestions.toList(growable: false);
  }
}

class _RecipeCreateContent extends StatelessWidget {
  const _RecipeCreateContent({
    required this.scrollController,
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

  final ScrollController scrollController;
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeCreateHeroPanel(
          imageUrl: imageUrl,
          titleController: titleController,
          descriptionController: descriptionController,
          tags: tags,
          isAddingTag: isAddingTag,
          tagController: tagController,
          tagFocusNode: tagFocusNode,
          tagSuggestions: tagSuggestions,
          duration: duration,
          difficulty: difficulty,
          category: category,
          onEditDuration: onEditDuration,
          onEditDifficulty: onEditDifficulty,
          onEditCategory: onEditCategory,
          onSubmitTag: onSubmitTag,
          onRemoveTag: onRemoveTag,
          onAddTagPressed: onAddTagPressed,
          onCancelTagInput: onCancelTagInput,
          onPickImage: onPickImage,
        ),
        const SizedBox(height: AppSpacing.xl),
        _RecipeBodyEditor(scrollController: scrollController),
      ],
    );
  }
}
