// ignore_for_file: unused_import

import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/features/categories/presentation/pages/categories_page.dart';
import 'package:frontend/features/home/presentation/widgets/category_card.dart';
import 'package:frontend/features/home/presentation/widgets/hero_section.dart';
import 'package:frontend/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/features/recipes/presentation/pages/recipe_create_page.dart';
import 'package:frontend/features/recipes/presentation/pages/recipe_details_page.dart';
import 'package:frontend/features/recipes/presentation/pages/recipes_page.dart';
import 'package:frontend/shared/bookmarks/bookmark_button.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

import '../../../support/widget_test_harness.dart';

void main() {
  testWidgets('opens recipe creation page from direct route', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await tester.pumpAndSettle();

    Navigator.of(
      tester.element(find.byType(HomePage)),
    ).pushNamed(AppRouter.recipeCreate);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('recipe-create-page')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recipe-create-title-field')),
      findsOneWidget,
    );
    expect(find.text('Chef Sofia'), findsOneWidget);
    expect(find.byTooltip('Templates'), findsOneWidget);
    expect(find.byTooltip('Open block settings'), findsOneWidget);
  });

  testWidgets('keeps multi-unit cooking time visible without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('recipe-duration-chip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase Days'));
    await tester.tap(find.byTooltip('Increase Hours'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('1d 1h 20 min'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('limits cooking time to seven days', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('recipe-duration-chip')));
    await tester.pumpAndSettle();
    for (var day = 0; day < 7; day++) {
      await tester.tap(find.byTooltip('Increase Days'));
    }
    await tester.pump();
    expect(find.text('07'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase Days'));
    await tester.pump();
    expect(find.text('00'), findsWidgets);
    expect(find.text('08'), findsNothing);
  });

  testWidgets('creates only the selected non-empty tag with compact input', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const PageTestApp(child: RecipeCreatePage(usesMockData: true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('recipe-create-add-tag-chip')));
    await tester.pump();
    final input = find.byKey(const ValueKey('recipe-create-tag-input'));
    await tester.enterText(input, 'veg');
    await tester.pump();
    await tester.pump();
    expect(find.text('Vegan'), findsOneWidget);
    await tester.tap(find.text('Vegan').last);
    await tester.pumpAndSettle();

    final veganChip = find.byKey(
      const ValueKey('recipe-create-tag-chip-vegan'),
    );
    expect(veganChip, findsOneWidget);
    expect(
      find.byKey(const ValueKey('recipe-create-tag-chip-veg')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('recipe-create-add-tag-chip')));
    await tester.pump();
    expect(
      tester
          .getSize(find.byKey(const ValueKey('recipe-create-tag-input-shell')))
          .height,
      tester.getSize(veganChip).height,
    );
    expect(
      tester.widget<TextField>(input).decoration?.hoverColor,
      Colors.transparent,
    );

    await tester.enterText(input, '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('recipe-create-tag-chip-item')),
      findsNothing,
    );
    expect(find.text('Item'), findsNothing);
  });

  testWidgets('adds recipe body blocks from create editor palette', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Blocks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Paragraph'));
    await tester.pumpAndSettle();

    expect(
      find.text('Write the cooking detail directly in the page preview.'),
      findsOneWidget,
    );
  });

  testWidgets('renders heading and paragraph as single styled text blocks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Blocks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Heading'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Paragraph'));
    await tester.pumpAndSettle();

    final heading = find.byKey(const ValueKey('heading-4-body'));
    final paragraph = find.byKey(const ValueKey('paragraph-5-body'));
    EditableText editableText(Finder field) => tester.widget<EditableText>(
      find.descendant(of: field, matching: find.byType(EditableText)),
    );

    expect(heading, findsOneWidget);
    expect(paragraph, findsOneWidget);
    expect(find.byKey(const ValueKey('heading-4-title')), findsNothing);
    expect(find.byKey(const ValueKey('paragraph-5-title')), findsNothing);
    expect(editableText(heading).style.fontSize, 30);
    expect(editableText(paragraph).style.fontSize, 16);
  });

  testWidgets('configures text content alignment and size presets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Blocks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Heading'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open block settings'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('recipe-inspector-tab-content')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-text-align-justify')),
      findsNothing,
    );
    await tester.tap(find.byKey(const ValueKey('recipe-text-align-center')));
    await tester.pumpAndSettle();
    EditableText editableText(Finder field) => tester.widget<EditableText>(
      find.descendant(of: field, matching: find.byType(EditableText)),
    );
    expect(
      editableText(find.byKey(const ValueKey('heading-4-body'))).textAlign,
      TextAlign.center,
    );

    await tester.tap(
      find.byKey(const ValueKey('recipe-text-size-heading-4-medium')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Large').last);
    await tester.pumpAndSettle();
    expect(
      editableText(find.byKey(const ValueKey('heading-4-body'))).style.fontSize,
      38,
    );

    await tester.tap(find.byTooltip('Paragraph'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('recipe-text-align-justify')));
    await tester.pumpAndSettle();
    expect(
      editableText(find.byKey(const ValueKey('paragraph-5-body'))).textAlign,
      TextAlign.justify,
    );
  });

  testWidgets('renders quotes with optional author content', (tester) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Blocks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quote'));
    await tester.pumpAndSettle();

    final quote = find.byKey(const ValueKey('quote-4-body'));
    final author = find.byKey(const ValueKey('quote-4-quote-author'));
    expect(quote, findsOneWidget);
    expect(author, findsOneWidget);
    expect(find.byKey(const ValueKey('quote-4-title')), findsNothing);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(of: quote, matching: find.byType(EditableText)),
          )
          .style
          .fontStyle,
      FontStyle.italic,
    );
    expect(find.text('Quote author (optional)'), findsOneWidget);

    await tester.enterText(author, 'Chef Sofia');
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(of: author, matching: find.byType(EditableText)),
          )
          .controller
          .text,
      'Chef Sofia',
    );

    await tester.tap(find.byTooltip('Open block settings'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('recipe-inspector-tab-content')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('recipe-quote-line-right')));
    await tester.pumpAndSettle();

    final quoteSurface = tester.widget<Container>(
      find.byKey(const ValueKey('quote-4-quote-surface')),
    );
    final quoteBorder =
        (quoteSurface.decoration! as BoxDecoration).border! as Border;
    expect(quoteBorder.left.style, BorderStyle.none);
    expect(quoteBorder.right.width, 3);
  });

  testWidgets('configures photo blocks as collage or autoplay slider', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Blocks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Photo'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('recipe-editor-block-image-4')),
        matching: find.byKey(const ValueKey('recipe-image-placeholder')),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Open block settings'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('recipe-inspector-tab-content')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Single photo'), findsOneWidget);
    expect(find.text('Upload photo'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recipe-media-align-center')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('recipe-image-mode-single')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Collage').last);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('recipe-image-mode-collage')),
      findsOneWidget,
    );
    expect(find.text('Add first photo'), findsOneWidget);
    final collagePlaceholder = find.descendant(
      of: find.byKey(const ValueKey('recipe-editor-block-image-4')),
      matching: find.byKey(const ValueKey('recipe-image-placeholder')),
    );
    expect(
      tester
          .widget<AspectRatio>(
            find.descendant(
              of: collagePlaceholder,
              matching: find.byType(AspectRatio),
            ),
          )
          .aspectRatio,
      2.4,
    );

    await tester.tap(find.byKey(const ValueKey('recipe-image-mode-collage')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Slider').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'Autoplay'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-slider-pace-balanced')),
      findsOneWidget,
    );
  });

  testWidgets('configures YouTube video blocks from block and inspector', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Blocks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Video'));
    await tester.pumpAndSettle();

    final placeholder = find.byKey(const ValueKey('recipe-video-placeholder'));
    expect(placeholder, findsOneWidget);
    expect(
      tester
          .widget<AspectRatio>(
            find.descendant(
              of: placeholder,
              matching: find.byType(AspectRatio),
            ),
          )
          .aspectRatio,
      1,
    );

    await tester.tap(placeholder);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('recipe-youtube-url-dialog')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('recipe-youtube-url-field')),
      'https://example.com/video',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid YouTube URL.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('recipe-youtube-url-field')),
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('recipe-youtube-preview')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Open block settings'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('recipe-inspector-tab-content')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('recipe-video-url-inspector-field')),
      findsOneWidget,
    );
    expect(find.text('Video size'), findsOneWidget);
  });

  testWidgets('configures note tone and divider line presets', (tester) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Blocks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Note'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('note-4-note-surface')), findsOneWidget);
    expect(find.byKey(const ValueKey('note-4-title')), findsNothing);

    await tester.tap(find.byTooltip('Open block settings'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('recipe-inspector-tab-content')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('recipe-note-tone-tip')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Warning').last);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('recipe-note-tone-warning')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Divider'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('recipe-editor-block-divider-5')),
        matching: find.byKey(const ValueKey('recipe-divider-preview')),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('recipe-divider-style-solid')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dash-dot').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('recipe-divider-thickness-regular')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bold').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('recipe-divider-color-4')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-divider-style-dashDot')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipe-divider-thickness-bold')),
      findsOneWidget,
    );
  });

  testWidgets('inserts a clicked palette block after the selected block', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('recipe-editor-block-ingredients-2')),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Blocks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Paragraph'));
    await tester.pumpAndSettle();

    final paragraph = find.byKey(
      const ValueKey('recipe-editor-block-paragraph-4'),
    );
    expect(paragraph, findsOneWidget);
    expect(
      tester.getTopLeft(paragraph).dy,
      greaterThan(
        tester
            .getTopLeft(
              find.byKey(const ValueKey('recipe-editor-block-ingredients-2')),
            )
            .dy,
      ),
    );
    expect(
      tester.getTopLeft(paragraph).dy,
      lessThan(
        tester
            .getTopLeft(
              find.byKey(const ValueKey('recipe-editor-block-steps-3')),
            )
            .dy,
      ),
    );
    expect(
      find.byKey(const ValueKey('recipe-block-insert-zone-root-1')),
      findsOneWidget,
    );
  });

  testWidgets(
    'shows one active block tab and appends after clearing selection',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('recipe-editor-block-handle-section-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('recipe-editor-block-handle-ingredients-2')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('recipe-editor-block-ingredients-2')),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('recipe-editor-block-handle-section-1')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('recipe-editor-block-handle-ingredients-2')),
        findsOneWidget,
      );

      final canvasRect = tester.getRect(
        find.byKey(const ValueKey('recipe-editor-canvas')),
      );
      await tester.tapAt(canvasRect.topLeft + const Offset(6, 6));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('recipe-editor-block-handle-ingredients-2')),
        findsNothing,
      );

      await tester.tap(find.byTooltip('Blocks'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Paragraph'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('recipe-block-insert-zone-root-2')),
        findsOneWidget,
      );
    },
  );

  testWidgets('resizes the active recipe block from its bottom edge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    final block = find.byKey(
      const ValueKey('recipe-editor-block-ingredients-2'),
    );
    await tester.tap(block);
    await tester.pumpAndSettle();

    final handle = find.byKey(
      const ValueKey('recipe-editor-block-resize-ingredients-2'),
    );
    final initialHeight = tester.getSize(block).height;

    await tester.drag(handle, const Offset(0, 90));
    await tester.pumpAndSettle();
    final expandedHeight = tester.getSize(block).height;

    expect(expandedHeight, greaterThan(initialHeight + 70));

    await tester.drag(handle, const Offset(0, -50));
    await tester.pumpAndSettle();
    final reducedHeight = tester.getSize(block).height;

    expect(reducedHeight, lessThan(expandedHeight - 35));
    expect(reducedHeight, greaterThanOrEqualTo(initialHeight));
  });

  testWidgets('final plus cues block icons and appends the next block', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    final insertZone = find.byKey(
      const ValueKey('recipe-block-insert-zone-root-1'),
    );
    await tester.ensureVisible(insertZone);
    await tester.tap(insertZone);
    await tester.pump();

    expect(find.byTooltip('Paragraph'), findsOneWidget);
    final cue = find.byKey(const ValueKey('recipe-palette-cue-paragraph'));
    double cueOpacity() => tester.widget<FadeTransition>(cue).opacity.value;

    for (var pulse = 0; pulse < 3; pulse++) {
      await tester.pump(const Duration(milliseconds: 150));
      expect(cueOpacity(), lessThan(0.5));
      await tester.pump(const Duration(milliseconds: 150));
      expect(cueOpacity(), greaterThan(0.9));
    }

    await tester.tap(find.byTooltip('Paragraph'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-editor-block-paragraph-4')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipe-block-insert-zone-root-2')),
      findsOneWidget,
    );
  });

  testWidgets('drags a new palette block into a chosen nested drop zone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Blocks'));
    await tester.pumpAndSettle();

    final source = find.byKey(const ValueKey('recipe-palette-drag-paragraph'));
    final target = find.byKey(const ValueKey('recipe-drop-zone-section-1-1'));
    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump(const Duration(milliseconds: 80));
    await gesture.moveTo(
      tester.getCenter(target),
      timeStamp: const Duration(milliseconds: 240),
    );
    await tester.pump(const Duration(milliseconds: 220));
    await gesture.up();
    await tester.pumpAndSettle();

    final paragraph = find.byKey(
      const ValueKey('recipe-editor-block-paragraph-4'),
    );
    expect(paragraph, findsOneWidget);
    expect(
      tester.getTopLeft(paragraph).dy,
      greaterThan(
        tester
            .getTopLeft(
              find.byKey(const ValueKey('recipe-editor-block-ingredients-2')),
            )
            .dy,
      ),
    );
    expect(
      tester.getTopLeft(paragraph).dy,
      lessThan(
        tester
            .getTopLeft(
              find.byKey(const ValueKey('recipe-editor-block-steps-3')),
            )
            .dy,
      ),
    );
  });

  testWidgets('expands recipe editor docks without resizing canvas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Expand block palette'), findsOneWidget);
    expect(find.byTooltip('Open block settings'), findsOneWidget);

    await tester.tap(find.byTooltip('Expand block palette'));
    await tester.pumpAndSettle();
    expect(find.text('Classic method'), findsOneWidget);
    expect(find.byTooltip('Collapse block palette'), findsOneWidget);

    await tester.tap(find.byTooltip('Open block settings'));
    await tester.pumpAndSettle();
    expect(find.text('Width'), findsOneWidget);
    expect(find.byTooltip('Collapse block settings'), findsOneWidget);
    expect(find.byTooltip('Expand block palette'), findsOneWidget);
  });

  testWidgets('shows compact template preview and one final insert zone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    expect(find.text('24 recipes'), findsOneWidget);
    expect(find.text('More recipes'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recipe-block-insert-zone-root-1')),
      findsOneWidget,
    );
    expect(find.text('Ingredients beside numbered steps.'), findsNothing);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(
      tester.getCenter(
        find.byKey(const ValueKey('compact-template-Classic method')),
      ),
    );
    await tester.pump();

    expect(find.text('Ingredients beside numbered steps.'), findsOneWidget);
  });

  testWidgets('keeps nested block selection isolated from its parent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Duplicate block'), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('recipe-editor-block-ingredients-2')),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Open block settings'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recipe-inspector-block-ingredients-2')),
      findsOneWidget,
    );
  });

  testWidgets('moves recipe blocks between root and nested containers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PageTestApp(child: RecipeCreatePage()));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('recipe-editor-block-ingredients-2')),
    );
    await tester.pump();

    Future<void> dragBlock({
      required Finder handle,
      required Finder target,
      required bool escapeParent,
    }) async {
      final gesture = await tester.startGesture(tester.getCenter(handle));
      await tester.pump(const Duration(milliseconds: 180));
      final targetRect = tester.getRect(target);
      final targetOffset = Offset(
        escapeParent
            ? targetRect.left + (targetRect.width * 0.55)
            : targetRect.center.dx,
        targetRect.center.dy,
      );
      await gesture.moveTo(
        targetOffset,
        timeStamp: const Duration(milliseconds: 360),
      );
      await tester.pump(const Duration(milliseconds: 220));
      await gesture.up();
      await tester.pumpAndSettle();
    }

    await dragBlock(
      handle: find.byKey(
        const ValueKey('recipe-editor-block-handle-ingredients-2'),
      ),
      target: find.byKey(const ValueKey('recipe-block-insert-zone-root-1')),
      escapeParent: true,
    );
    expect(
      find.byKey(const ValueKey('recipe-block-insert-zone-root-2')),
      findsOneWidget,
    );

    await dragBlock(
      handle: find.byKey(
        const ValueKey('recipe-editor-block-handle-ingredients-2'),
      ),
      target: find.byKey(const ValueKey('recipe-drop-zone-section-1-1')),
      escapeParent: false,
    );
    expect(
      find.byKey(const ValueKey('recipe-block-insert-zone-root-1')),
      findsOneWidget,
    );
  });
}
