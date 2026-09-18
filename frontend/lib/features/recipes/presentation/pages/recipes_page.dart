import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/localization/app_strings.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/core/widgets/responsive_sliver_grid.dart';
import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/features/recipes/presentation/controllers/recipe_collection_controller.dart';
import 'package:frontend/features/recipes/presentation/controllers/recipe_query_controller.dart';
import 'package:frontend/features/recipes/presentation/widgets/recipe_collection_states.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

part '../widgets/recipes/recipe_catalog_sections.dart';
part '../widgets/recipes/recipe_filter_controls.dart';
part '../widgets/recipes/recipe_search_controls.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({
    super.key,
    this.recipeRepository = const ApiRecipeRepository(),
    this.initialCategoryIds = const [],
    this.initialTagIds = const [],
    this.initialAuthorIds = const [],
    this.initialQuery,
  });

  final RecipeRepository recipeRepository;
  final List<String> initialCategoryIds;
  final List<String> initialTagIds;
  final List<String> initialAuthorIds;
  final String? initialQuery;

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  static const _maxSelectedCategories = 3;
  static const _recipesPerPage = 20;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _query = '';
  Set<String> _selectedCategoryIds = const {};
  Set<String> _selectedTagIds = const {};
  Set<String> _selectedAuthorIds = const {};
  RecipeTimeFilter _timeFilter = RecipeTimeFilter.any;
  RecipeSort _sort = RecipeSort.featured;
  bool _savedOnly = false;
  List<RecipeModel> _recipes = const [];
  late final RecipeCollectionController _recipesController;
  late RecipeQueryIndex _recipeIndex;
  RecipeFilterCacheKey? _visibleRecipesCacheKey;
  List<RecipeModel> _visibleRecipesCache = const [];
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _recipesController = RecipeCollectionController(
      repository: widget.recipeRepository,
    )..addListener(_handleRecipeCollectionChanged);
    _recipeIndex = RecipeQueryIndex(_recipes);
    _selectedCategoryIds = _normalizedInitialCategoryIds(
      widget.initialCategoryIds,
    );
    _selectedTagIds = _normalizedTagIds(widget.initialTagIds);
    _selectedAuthorIds = _normalizedAuthorIds(widget.initialAuthorIds);
    _query = widget.initialQuery?.trim() ?? '';
    _searchController.text = _query;
    unawaited(_recipesController.load());
  }

  @override
  void didUpdateWidget(covariant RecipesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeRepository != widget.recipeRepository) {
      _recipesController.replaceRepository(widget.recipeRepository);
      unawaited(_recipesController.load());
    }
    if (!_sameCategoryIds(
      oldWidget.initialCategoryIds,
      widget.initialCategoryIds,
    )) {
      _selectedCategoryIds = _normalizedInitialCategoryIds(
        widget.initialCategoryIds,
      );
      _currentPage = 1;
    }
    if (!_sameNormalizedIds(oldWidget.initialTagIds, widget.initialTagIds)) {
      _selectedTagIds = _normalizedTagIds(widget.initialTagIds);
      _currentPage = 1;
    }
    if (!_sameNormalizedIds(
      oldWidget.initialAuthorIds,
      widget.initialAuthorIds,
    )) {
      _selectedAuthorIds = _normalizedAuthorIds(widget.initialAuthorIds);
      _currentPage = 1;
    }
    if (oldWidget.initialQuery != widget.initialQuery) {
      _query = widget.initialQuery?.trim() ?? '';
      _searchController.text = _query;
      _currentPage = 1;
    }
  }

  @override
  void dispose() {
    _recipesController
      ..removeListener(_handleRecipeCollectionChanged)
      ..dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleRecipeCollectionChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      final recipes = _recipesController.recipes;
      if (!_sameRecipeLists(_recipes, recipes)) {
        _replaceRecipes(recipes);
      }
    });
  }

  void _replaceRecipes(List<RecipeModel> recipes) {
    _recipes = recipes;
    _recipeIndex = RecipeQueryIndex(recipes);
    _visibleRecipesCacheKey = null;
    _visibleRecipesCache = const [];
    _currentPage = 1;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
    final bottomPadding = AppSpacing.sectionGapForWidth(viewportWidth);
    final recipes = _visibleRecipes(context);
    final pageCount = _pageCount(recipes.length);
    final currentPage = _currentPage.clamp(1, pageCount).toInt();
    final pageRecipes = _recipesForPage(recipes, currentPage);
    final categories = _recipeIndex.categories;

    return Scaffold(
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
              // ignore: deprecated_member_use
              cacheExtent: 160,
              slivers: [
                _RecipesContentSliver(
                  topPadding: headerHeight + AppSpacing.xl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RecipesHeader(totalCount: recipes.length),
                      const SizedBox(height: AppSpacing.lg),
                      _RecipeControls(
                        searchController: _searchController,
                        selectedCategoryIds: _selectedCategoryIds,
                        selectedTags: _recipeIndex.selectedTagTokens(
                          _selectedTagIds,
                        ),
                        selectedAuthors: _recipeIndex.selectedAuthorTokens(
                          _selectedAuthorIds,
                        ),
                        timeFilter: _timeFilter,
                        sort: _sort,
                        savedOnly: _savedOnly,
                        categories: categories,
                        recipeIndex: _recipeIndex,
                        onSearchChanged: (value) {
                          setState(() {
                            _query = value;
                            _currentPage = 1;
                          });
                        },
                        onClearSearch: _clearSearchFilters,
                        onTagSelected: _selectTag,
                        onTagRemoved: _removeSelectedTag,
                        onAuthorSelected: _selectAuthor,
                        onAuthorRemoved: _removeSelectedAuthor,
                        onCategoryToggled: _toggleCategory,
                        onClearCategories: () {
                          setState(() {
                            _selectedCategoryIds = const {};
                            _currentPage = 1;
                          });
                        },
                        onTimeFilterChanged: (filter) {
                          setState(() {
                            _timeFilter = filter;
                            _currentPage = 1;
                          });
                        },
                        onSortChanged: (sort) {
                          setState(() {
                            _sort = sort;
                            _currentPage = 1;
                          });
                        },
                        onSavedOnlyChanged: (value) {
                          setState(() {
                            _savedOnly = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (_recipesController.isLoading && _recipes.isEmpty)
                  _RecipesContentSliver(
                    topPadding: AppSpacing.lg,
                    bottomPadding: bottomPadding,
                    child: const RecipeCollectionLoading(),
                  )
                else if (_recipesController.hasError && _recipes.isEmpty)
                  _RecipesContentSliver(
                    topPadding: AppSpacing.lg,
                    bottomPadding: bottomPadding,
                    child: RecipeCollectionError(
                      error: _recipesController.error,
                      onRetry: () => unawaited(_recipesController.load()),
                    ),
                  )
                else if (recipes.isEmpty)
                  _RecipesContentSliver(
                    topPadding: AppSpacing.lg,
                    bottomPadding: bottomPadding,
                    child: const _EmptyRecipesState(),
                  )
                else
                  _RecipesGrid(
                    recipes: pageRecipes,
                    topPadding: AppSpacing.lg,
                    bottomPadding: pageCount > 1
                        ? AppSpacing.lg
                        : bottomPadding,
                  ),
                if (pageCount > 1)
                  _RecipesContentSliver(
                    bottomPadding: bottomPadding,
                    child: _RecipePagination(
                      currentPage: currentPage,
                      pageCount: pageCount,
                      onPageChanged: _changePage,
                    ),
                  ),
              ],
            ),
            _RecipesHeaderShell(height: headerHeight, child: const AppHeader()),
          ],
        ),
      ),
    );
  }

  List<RecipeModel> _visibleRecipes(BuildContext context) {
    final bookmarkStore = BookmarkScope.of(context);
    final cacheKey = RecipeFilterCacheKey(
      query: _query,
      selectedCategoryIds: _selectedCategoryIds,
      selectedTagIds: _selectedTagIds,
      selectedAuthorIds: _selectedAuthorIds,
      timeFilter: _timeFilter,
      sort: _sort,
      savedOnly: _savedOnly,
      bookmarkVersion: _savedOnly ? bookmarkStore.version : 0,
    );

    if (_visibleRecipesCacheKey == cacheKey) {
      return _visibleRecipesCache;
    }

    final recipes = _recipeIndex.visibleRecipes(
      query: _query,
      selectedCategoryIds: _selectedCategoryIds,
      selectedTagIds: _selectedTagIds,
      selectedAuthorIds: _selectedAuthorIds,
      timeFilter: _timeFilter,
      sort: _sort,
      savedOnly: _savedOnly,
      isRecipeSaved: bookmarkStore.isRecipeSaved,
    );

    _visibleRecipesCacheKey = cacheKey;
    _visibleRecipesCache = recipes;
    return recipes;
  }

  void _toggleCategory(String categoryId) {
    final normalizedCategoryId = CategoryCatalog.slug(categoryId);
    setState(() {
      final selectedCategoryIds = {..._selectedCategoryIds};
      if (selectedCategoryIds.contains(normalizedCategoryId)) {
        selectedCategoryIds.remove(normalizedCategoryId);
      } else if (selectedCategoryIds.length < _maxSelectedCategories) {
        selectedCategoryIds.add(normalizedCategoryId);
      }
      _selectedCategoryIds = selectedCategoryIds;
      _currentPage = 1;
    });
  }

  int _pageCount(int itemCount) {
    if (itemCount <= 0) {
      return 1;
    }

    return ((itemCount - 1) ~/ _recipesPerPage) + 1;
  }

  List<RecipeModel> _recipesForPage(List<RecipeModel> recipes, int page) {
    if (recipes.isEmpty) {
      return const [];
    }

    final startIndex = (page - 1) * _recipesPerPage;
    return recipes
        .skip(startIndex)
        .take(_recipesPerPage)
        .toList(growable: false);
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Set<String> _normalizedInitialCategoryIds(Iterable<String> categoryIds) {
    return categoryIds
        .map(CategoryCatalog.slug)
        .where((categoryId) => CategoryCatalog.findById(categoryId) != null)
        .take(_maxSelectedCategories)
        .toSet();
  }

  bool _sameCategoryIds(List<String> left, List<String> right) {
    final normalizedLeft = _normalizedInitialCategoryIds(left);
    final normalizedRight = _normalizedInitialCategoryIds(right);
    return normalizedLeft.length == normalizedRight.length &&
        normalizedLeft.containsAll(normalizedRight);
  }

  Set<String> _normalizedTagIds(Iterable<String> tagIds) {
    return tagIds.map(_tagId).where((tagId) => tagId.isNotEmpty).toSet();
  }

  Set<String> _normalizedAuthorIds(Iterable<String> authorIds) {
    return authorIds
        .map(_authorId)
        .where((authorId) => authorId.isNotEmpty)
        .toSet();
  }

  bool _sameNormalizedIds(Iterable<String> left, Iterable<String> right) {
    final normalizedLeft = left.map(_tagId).toSet();
    final normalizedRight = right.map(_tagId).toSet();
    return normalizedLeft.length == normalizedRight.length &&
        normalizedLeft.containsAll(normalizedRight);
  }

  void _removeSelectedTag(String tagId) {
    setState(() {
      _selectedTagIds = {..._selectedTagIds}..remove(tagId);
      _currentPage = 1;
    });
  }

  void _selectTag(String tag) {
    final tagId = _tagId(tag);
    if (tagId.isEmpty || _selectedTagIds.contains(tagId)) {
      return;
    }

    _searchController.clear();
    setState(() {
      _query = '';
      _selectedTagIds = {..._selectedTagIds, tagId};
      _currentPage = 1;
    });
  }

  void _selectAuthor(String author) {
    final authorId = _authorId(author);
    if (authorId.isEmpty || _selectedAuthorIds.contains(authorId)) {
      return;
    }

    _searchController.clear();
    setState(() {
      _query = '';
      _selectedAuthorIds = {..._selectedAuthorIds, authorId};
      _currentPage = 1;
    });
  }

  void _removeSelectedAuthor(String authorId) {
    setState(() {
      _selectedAuthorIds = {..._selectedAuthorIds}..remove(authorId);
      _currentPage = 1;
    });
  }

  void _clearSearchFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedTagIds = const {};
      _selectedAuthorIds = const {};
      _currentPage = 1;
    });
  }

  String _tagId(String tag) {
    return CategoryCatalog.slug(tag);
  }

  String _authorId(String author) {
    return CategoryCatalog.slug(author);
  }
}

bool _sameRecipeLists(List<RecipeModel> left, List<RecipeModel> right) {
  if (identical(left, right)) {
    return true;
  }
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index++) {
    if (!_sameRecipe(left[index], right[index])) {
      return false;
    }
  }
  return true;
}

bool _sameRecipe(RecipeModel left, RecipeModel right) {
  return left.id == right.id &&
      left.title == right.title &&
      left.categoryId == right.categoryId &&
      left.categoryName == right.categoryName &&
      left.author == right.author &&
      left.minutes == right.minutes &&
      left.rating == right.rating &&
      left.accentColor == right.accentColor &&
      left.description == right.description &&
      left.imageUrl == right.imageUrl &&
      left.thumbnailUrl == right.thumbnailUrl &&
      left.popularityScore == right.popularityScore &&
      left.isSaved == right.isSaved &&
      _sameStringLists(left.tags, right.tags);
}

bool _sameStringLists(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}
