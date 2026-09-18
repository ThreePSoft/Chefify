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

const featuredRecipe = RecipeModel(
  id: 'citrus-herb-chicken-quinoa',
  title: 'Citrus Herb Chicken with Warm Quinoa',
  categoryId: 'healthy',
  categoryName: 'Healthy',
  author: 'Chef Luna',
  minutes: 40,
  rating: 4.9,
  accentColor: Color(0xFF5F7C67),
  tags: ['chef-pick', 'chicken', 'high-protein'],
);

const testCategory = CategoryModel(
  id: 'quick-meals',
  title: 'Quick Meals',
  description: '30-minute dishes for busy days.',
  icon: Icons.flash_on_rounded,
  recipesCount: 124,
);

class TestApp extends StatefulWidget {
  const TestApp({
    super.key,
    required this.child,
    this.initialBookmarks = const BookmarkSnapshot(),
  });

  final Widget child;
  final BookmarkSnapshot initialBookmarks;

  @override
  State<TestApp> createState() => TestAppState();
}

class PageTestApp extends StatefulWidget {
  const PageTestApp({super.key, required this.child});

  final Widget child;

  @override
  State<PageTestApp> createState() => PageTestAppState();
}

class PageTestAppState extends State<PageTestApp> {
  late final AppSettingsController _settingsController;
  late final BookmarkStore _bookmarkStore;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController();
    _bookmarkStore = BookmarkStore.memory();
  }

  @override
  void dispose() {
    _settingsController.dispose();
    _bookmarkStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BookmarkScope(
      store: _bookmarkStore,
      child: AppSettingsScope(
        controller: _settingsController,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _settingsController.themeMode,
          home: widget.child,
        ),
      ),
    );
  }
}

class TestAppState extends State<TestApp> {
  late final AppSettingsController _settingsController;
  late final BookmarkStore _bookmarkStore;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController();
    _bookmarkStore = BookmarkStore.memory(widget.initialBookmarks);
  }

  @override
  void dispose() {
    _settingsController.dispose();
    _bookmarkStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BookmarkScope(
      store: _bookmarkStore,
      child: AppSettingsScope(
        controller: _settingsController,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _settingsController.themeMode,
          home: Scaffold(body: SingleChildScrollView(child: widget.child)),
        ),
      ),
    );
  }
}
