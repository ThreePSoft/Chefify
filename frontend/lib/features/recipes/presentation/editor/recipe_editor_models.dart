part of '../pages/recipe_create_page.dart';

enum _RecipeEditorTab { templates, blocks }

enum _RecipeBlockGroup { content, recipe, widgets, layout }

enum _RecipeBlockKind {
  section,
  columns,
  column,
  card,
  photoText,
  heading,
  paragraph,
  quote,
  image,
  video,
  note,
  divider,
  ingredients,
  steps,
  equipment,
  substitutions,
  nutrition,
  timer,
  servings,
  checklist,
}

enum _RecipeBlockWidth { narrow, normal, wide, full }

enum _RecipeBlockAlignment { left, center, right }

enum _RecipeBlockSpacing { compact, normal, spacious }

enum _RecipeBlockVariant { simple, cards, timeline }

enum _RecipeTextAlignment { left, center, right, justify }

enum _RecipeTextSize { extraSmall, small, medium, large, extraLarge }

enum _RecipeInspectorTab { block, content }

enum _RecipeQuoteLineSide { left, right }

enum _RecipeImageMode { single, collage, slider }

enum _RecipeMediaAlignment { left, center, right }

enum _RecipeMediaSize { extraSmall, small, medium, large, extraLarge }

enum _RecipeSliderPace { relaxed, balanced, quick }

enum _RecipeNoteTone { tip, info, warning, important }

enum _RecipeDividerStyle { solid, dotted, dashed, dashDot, doubleLine }

enum _RecipeDividerThickness { thin, regular, bold }

extension _RecipeBlockKindDetails on _RecipeBlockKind {
  String get label {
    return switch (this) {
      _RecipeBlockKind.section => 'Section',
      _RecipeBlockKind.columns => 'Columns',
      _RecipeBlockKind.column => 'Column',
      _RecipeBlockKind.card => 'Card',
      _RecipeBlockKind.photoText => 'Photo + text',
      _RecipeBlockKind.heading => 'Heading',
      _RecipeBlockKind.paragraph => 'Paragraph',
      _RecipeBlockKind.quote => 'Quote',
      _RecipeBlockKind.image => 'Photo',
      _RecipeBlockKind.video => 'Video',
      _RecipeBlockKind.note => 'Note',
      _RecipeBlockKind.divider => 'Divider',
      _RecipeBlockKind.ingredients => 'Ingredients',
      _RecipeBlockKind.steps => 'Steps',
      _RecipeBlockKind.equipment => 'Equipment',
      _RecipeBlockKind.substitutions => 'Substitutions',
      _RecipeBlockKind.nutrition => 'Nutrition',
      _RecipeBlockKind.timer => 'Timer',
      _RecipeBlockKind.servings => 'Serving calculator',
      _RecipeBlockKind.checklist => 'Checklist',
    };
  }

  IconData get icon {
    return switch (this) {
      _RecipeBlockKind.section => Icons.view_agenda_rounded,
      _RecipeBlockKind.columns => Icons.view_column_rounded,
      _RecipeBlockKind.column => Icons.view_stream_rounded,
      _RecipeBlockKind.card => Icons.crop_square_rounded,
      _RecipeBlockKind.photoText => Icons.view_week_rounded,
      _RecipeBlockKind.heading => Icons.title_rounded,
      _RecipeBlockKind.paragraph => Icons.notes_rounded,
      _RecipeBlockKind.quote => Icons.format_quote_rounded,
      _RecipeBlockKind.image => Icons.image_rounded,
      _RecipeBlockKind.video => Icons.smart_display_rounded,
      _RecipeBlockKind.note => Icons.sticky_note_2_rounded,
      _RecipeBlockKind.divider => Icons.horizontal_rule_rounded,
      _RecipeBlockKind.ingredients => Icons.local_dining_rounded,
      _RecipeBlockKind.steps => Icons.format_list_numbered_rounded,
      _RecipeBlockKind.equipment => Icons.soup_kitchen_rounded,
      _RecipeBlockKind.substitutions => Icons.sync_alt_rounded,
      _RecipeBlockKind.nutrition => Icons.monitor_heart_rounded,
      _RecipeBlockKind.timer => Icons.timer_rounded,
      _RecipeBlockKind.servings => Icons.calculate_rounded,
      _RecipeBlockKind.checklist => Icons.checklist_rounded,
    };
  }

  _RecipeBlockGroup get group {
    return switch (this) {
      _RecipeBlockKind.heading ||
      _RecipeBlockKind.paragraph ||
      _RecipeBlockKind.quote ||
      _RecipeBlockKind.image ||
      _RecipeBlockKind.video ||
      _RecipeBlockKind.note ||
      _RecipeBlockKind.divider => _RecipeBlockGroup.content,
      _RecipeBlockKind.ingredients ||
      _RecipeBlockKind.steps ||
      _RecipeBlockKind.equipment ||
      _RecipeBlockKind.substitutions ||
      _RecipeBlockKind.nutrition => _RecipeBlockGroup.recipe,
      _RecipeBlockKind.timer ||
      _RecipeBlockKind.servings ||
      _RecipeBlockKind.checklist => _RecipeBlockGroup.widgets,
      _RecipeBlockKind.section ||
      _RecipeBlockKind.columns ||
      _RecipeBlockKind.column ||
      _RecipeBlockKind.card ||
      _RecipeBlockKind.photoText => _RecipeBlockGroup.layout,
    };
  }

  bool get canContainChildren {
    return switch (this) {
      _RecipeBlockKind.section ||
      _RecipeBlockKind.columns ||
      _RecipeBlockKind.column ||
      _RecipeBlockKind.card => true,
      _ => false,
    };
  }

  bool get supportsTextSettings {
    return this == _RecipeBlockKind.heading ||
        this == _RecipeBlockKind.paragraph ||
        this == _RecipeBlockKind.quote;
  }

  bool get supportsJustifiedText {
    return this == _RecipeBlockKind.paragraph || this == _RecipeBlockKind.quote;
  }
}

@immutable
class _RecipeEditorBlock {
  const _RecipeEditorBlock({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.width = _RecipeBlockWidth.normal,
    this.alignment = _RecipeBlockAlignment.left,
    this.spacing = _RecipeBlockSpacing.normal,
    this.variant = _RecipeBlockVariant.simple,
    this.textAlignment = _RecipeTextAlignment.left,
    this.textSize = _RecipeTextSize.medium,
    this.quoteAuthor = '',
    this.quoteLineSide = _RecipeQuoteLineSide.left,
    this.imageMode = _RecipeImageMode.single,
    this.mediaAlignment = _RecipeMediaAlignment.center,
    this.mediaSize = _RecipeMediaSize.medium,
    this.imageUrls = const [],
    this.sliderAutoplay = false,
    this.sliderPace = _RecipeSliderPace.balanced,
    this.videoUrl = '',
    this.noteTone = _RecipeNoteTone.tip,
    this.dividerStyle = _RecipeDividerStyle.solid,
    this.dividerThickness = _RecipeDividerThickness.regular,
    this.dividerColorIndex = 0,
    this.editorHeight,
    this.children = const [],
  });

  final String id;
  final _RecipeBlockKind kind;
  final String title;
  final String body;
  final _RecipeBlockWidth width;
  final _RecipeBlockAlignment alignment;
  final _RecipeBlockSpacing spacing;
  final _RecipeBlockVariant variant;
  final _RecipeTextAlignment textAlignment;
  final _RecipeTextSize textSize;
  final String quoteAuthor;
  final _RecipeQuoteLineSide quoteLineSide;
  final _RecipeImageMode imageMode;
  final _RecipeMediaAlignment mediaAlignment;
  final _RecipeMediaSize mediaSize;
  final List<String> imageUrls;
  final bool sliderAutoplay;
  final _RecipeSliderPace sliderPace;
  final String videoUrl;
  final _RecipeNoteTone noteTone;
  final _RecipeDividerStyle dividerStyle;
  final _RecipeDividerThickness dividerThickness;
  final int dividerColorIndex;
  final double? editorHeight;
  final List<_RecipeEditorBlock> children;

  bool get canContainChildren => kind.canContainChildren;

  _RecipeEditorBlock copyWith({
    String? id,
    _RecipeBlockKind? kind,
    String? title,
    String? body,
    _RecipeBlockWidth? width,
    _RecipeBlockAlignment? alignment,
    _RecipeBlockSpacing? spacing,
    _RecipeBlockVariant? variant,
    _RecipeTextAlignment? textAlignment,
    _RecipeTextSize? textSize,
    String? quoteAuthor,
    _RecipeQuoteLineSide? quoteLineSide,
    _RecipeImageMode? imageMode,
    _RecipeMediaAlignment? mediaAlignment,
    _RecipeMediaSize? mediaSize,
    List<String>? imageUrls,
    bool? sliderAutoplay,
    _RecipeSliderPace? sliderPace,
    String? videoUrl,
    _RecipeNoteTone? noteTone,
    _RecipeDividerStyle? dividerStyle,
    _RecipeDividerThickness? dividerThickness,
    int? dividerColorIndex,
    double? editorHeight,
    List<_RecipeEditorBlock>? children,
  }) {
    return _RecipeEditorBlock(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      width: width ?? this.width,
      alignment: alignment ?? this.alignment,
      spacing: spacing ?? this.spacing,
      variant: variant ?? this.variant,
      textAlignment: textAlignment ?? this.textAlignment,
      textSize: textSize ?? this.textSize,
      quoteAuthor: quoteAuthor ?? this.quoteAuthor,
      quoteLineSide: quoteLineSide ?? this.quoteLineSide,
      imageMode: imageMode ?? this.imageMode,
      mediaAlignment: mediaAlignment ?? this.mediaAlignment,
      mediaSize: mediaSize ?? this.mediaSize,
      imageUrls: imageUrls ?? this.imageUrls,
      sliderAutoplay: sliderAutoplay ?? this.sliderAutoplay,
      sliderPace: sliderPace ?? this.sliderPace,
      videoUrl: videoUrl ?? this.videoUrl,
      noteTone: noteTone ?? this.noteTone,
      dividerStyle: dividerStyle ?? this.dividerStyle,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      dividerColorIndex: dividerColorIndex ?? this.dividerColorIndex,
      editorHeight: editorHeight ?? this.editorHeight,
      children: children ?? this.children,
    );
  }
}
