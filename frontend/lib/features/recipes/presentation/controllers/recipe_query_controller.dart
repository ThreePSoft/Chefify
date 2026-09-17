import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/shared/models/home_models.dart';

enum RecipeSort { featured, rating, quickest, title }

enum RecipeTimeFilter { any, under20, under30, over30 }

class RecipeSearchTagToken {
  const RecipeSearchTagToken({required this.id, required this.label});

  final String id;
  final String label;
}

class RecipeSearchAuthorToken {
  const RecipeSearchAuthorToken({required this.id, required this.name});

  final String id;
  final String name;
}

enum RecipeSearchSuggestionType { recipe, tag, author }

class RecipeSearchSuggestion {
  const RecipeSearchSuggestion({
    required this.type,
    required this.label,
    required this.value,
    this.trailingLabel,
  });

  final RecipeSearchSuggestionType type;
  final String label;
  final String value;
  final String? trailingLabel;
}

class RecipeFilterCacheKey {
  RecipeFilterCacheKey({
    required String query,
    required Set<String> selectedCategoryIds,
    required Set<String> selectedTagIds,
    required Set<String> selectedAuthorIds,
    required this.timeFilter,
    required this.sort,
    required this.savedOnly,
    required this.bookmarkVersion,
  }) : query = query.trim().toLowerCase(),
       categoryKey = _setKey(selectedCategoryIds),
       tagKey = _setKey(selectedTagIds),
       authorKey = _setKey(selectedAuthorIds);

  final String query;
  final String categoryKey;
  final String tagKey;
  final String authorKey;
  final RecipeTimeFilter timeFilter;
  final RecipeSort sort;
  final bool savedOnly;
  final int bookmarkVersion;

  @override
  bool operator ==(Object other) {
    return other is RecipeFilterCacheKey &&
        query == other.query &&
        categoryKey == other.categoryKey &&
        tagKey == other.tagKey &&
        authorKey == other.authorKey &&
        timeFilter == other.timeFilter &&
        sort == other.sort &&
        savedOnly == other.savedOnly &&
        bookmarkVersion == other.bookmarkVersion;
  }

  @override
  int get hashCode {
    return Object.hash(
      query,
      categoryKey,
      tagKey,
      authorKey,
      timeFilter,
      sort,
      savedOnly,
      bookmarkVersion,
    );
  }

  static String _setKey(Set<String> values) {
    if (values.isEmpty) {
      return '';
    }

    return (values.toList()..sort()).join('|');
  }
}

class RecipeQueryIndex {
  RecipeQueryIndex(List<RecipeModel> recipes)
    : _entries = _buildEntries(recipes),
      categories = _buildCategories(recipes),
      _tagSuggestions = _buildTagSuggestions(recipes),
      _authorSuggestions = _buildAuthorSuggestions(recipes),
      _tagLabelsById = _buildTagLabels(recipes),
      _authorNamesById = _buildAuthorNames(recipes);

  final List<_RecipeIndexEntry> _entries;
  final List<CategoryModel> categories;
  final List<_TagSuggestionEntry> _tagSuggestions;
  final List<_AuthorSuggestionEntry> _authorSuggestions;
  final Map<String, String> _tagLabelsById;
  final Map<String, String> _authorNamesById;

  List<RecipeModel> visibleRecipes({
    required String query,
    required Set<String> selectedCategoryIds,
    required Set<String> selectedTagIds,
    required Set<String> selectedAuthorIds,
    required RecipeTimeFilter timeFilter,
    required RecipeSort sort,
    required bool savedOnly,
    required bool Function(RecipeModel recipe) isRecipeSaved,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final normalizedSlugQuery = CategoryCatalog.slug(normalizedQuery);
    final matches = <_RecipeIndexEntry>[];

    for (final entry in _entries) {
      if (!_matchesSearch(entry, normalizedQuery, normalizedSlugQuery)) {
        continue;
      }
      if (selectedCategoryIds.isNotEmpty &&
          !selectedCategoryIds.any(entry.categoryIds.contains)) {
        continue;
      }
      if (selectedTagIds.isNotEmpty &&
          !selectedTagIds.every(entry.tagIds.contains)) {
        continue;
      }
      if (selectedAuthorIds.isNotEmpty &&
          !selectedAuthorIds.contains(entry.authorId)) {
        continue;
      }
      if (!_matchesTime(entry.recipe, timeFilter)) {
        continue;
      }
      if (savedOnly && !isRecipeSaved(entry.recipe)) {
        continue;
      }

      matches.add(entry);
    }

    matches.sort((left, right) {
      return switch (sort) {
        RecipeSort.featured => left.sourceIndex.compareTo(right.sourceIndex),
        RecipeSort.rating => right.recipe.rating.compareTo(left.recipe.rating),
        RecipeSort.quickest => left.recipe.minutes.compareTo(
          right.recipe.minutes,
        ),
        RecipeSort.title => left.recipe.title.compareTo(right.recipe.title),
      };
    });

    return [for (final entry in matches) entry.recipe];
  }

  List<RecipeSearchTagToken> selectedTagTokens(Set<String> selectedTagIds) {
    return [
      for (final tagId in selectedTagIds)
        RecipeSearchTagToken(
          id: tagId,
          label: _tagLabelsById[tagId] ?? _readableSearchLabel(tagId),
        ),
    ];
  }

  List<RecipeSearchAuthorToken> selectedAuthorTokens(
    Set<String> selectedAuthorIds,
  ) {
    return [
      for (final authorId in selectedAuthorIds)
        RecipeSearchAuthorToken(
          id: authorId,
          name: _authorNamesById[authorId] ?? _readableSearchLabel(authorId),
        ),
    ];
  }

  List<RecipeSearchSuggestion> suggestions({
    required String query,
    required Set<String> selectedTagIds,
    required Set<String> selectedAuthorIds,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final slugQuery = CategoryCatalog.slug(query);
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    return [
      ..._matchingTagSuggestions(
        normalizedQuery: normalizedQuery,
        slugQuery: slugQuery,
        selectedTagIds: selectedTagIds,
      ),
      ..._matchingAuthorSuggestions(
        normalizedQuery: normalizedQuery,
        slugQuery: slugQuery,
        selectedAuthorIds: selectedAuthorIds,
      ),
      ..._matchingRecipeSuggestions(
        normalizedQuery: normalizedQuery,
        slugQuery: slugQuery,
      ),
    ].take(8).toList(growable: false);
  }

  List<RecipeSearchSuggestion> _matchingRecipeSuggestions({
    required String normalizedQuery,
    required String slugQuery,
  }) {
    final matches = <_RecipeIndexEntry>[];
    final seenRecipeIds = <String>{};

    for (final entry in _entries) {
      final matchesTitle =
          entry.titleLower.contains(normalizedQuery) ||
          (slugQuery.isNotEmpty && entry.titleSlug.contains(slugQuery));
      if (!matchesTitle || !seenRecipeIds.add(entry.recipe.id)) {
        continue;
      }

      matches.add(entry);
    }

    matches.sort((left, right) {
      final rating = right.recipe.rating.compareTo(left.recipe.rating);
      if (rating != 0) {
        return rating;
      }
      return left.recipe.title.compareTo(right.recipe.title);
    });

    return [
      for (final entry in matches)
        RecipeSearchSuggestion(
          type: RecipeSearchSuggestionType.recipe,
          label: entry.recipe.title,
          value: entry.recipe.title,
        ),
    ];
  }

  List<RecipeSearchSuggestion> _matchingTagSuggestions({
    required String normalizedQuery,
    required String slugQuery,
    required Set<String> selectedTagIds,
  }) {
    final matches =
        [
          for (final tag in _tagSuggestions)
            if (!selectedTagIds.contains(tag.id) &&
                (tag.labelLower.contains(normalizedQuery) ||
                    tag.id.contains(slugQuery)))
              tag,
        ]..sort((left, right) {
          final count = right.count.compareTo(left.count);
          if (count != 0) {
            return count;
          }
          return left.label.compareTo(right.label);
        });

    return [
      for (final tag in matches)
        RecipeSearchSuggestion(
          type: RecipeSearchSuggestionType.tag,
          label: tag.label,
          value: tag.id,
          trailingLabel: 'tag',
        ),
    ];
  }

  List<RecipeSearchSuggestion> _matchingAuthorSuggestions({
    required String normalizedQuery,
    required String slugQuery,
    required Set<String> selectedAuthorIds,
  }) {
    final matches =
        [
          for (final author in _authorSuggestions)
            if (!selectedAuthorIds.contains(author.id) &&
                (author.nameLower.contains(normalizedQuery) ||
                    author.id.contains(slugQuery)))
              author,
        ]..sort((left, right) {
          final count = right.count.compareTo(left.count);
          if (count != 0) {
            return count;
          }
          return left.name.compareTo(right.name);
        });

    return [
      for (final author in matches)
        RecipeSearchSuggestion(
          type: RecipeSearchSuggestionType.author,
          label: author.name,
          value: author.id,
          trailingLabel: 'user',
        ),
    ];
  }

  static bool _matchesSearch(
    _RecipeIndexEntry entry,
    String normalizedQuery,
    String normalizedSlugQuery,
  ) {
    return normalizedQuery.isEmpty ||
        entry.searchText.contains(normalizedQuery) ||
        (normalizedSlugQuery.isNotEmpty &&
            entry.searchSlug.contains(normalizedSlugQuery));
  }

  static bool _matchesTime(RecipeModel recipe, RecipeTimeFilter timeFilter) {
    return switch (timeFilter) {
      RecipeTimeFilter.any => true,
      RecipeTimeFilter.under20 => recipe.minutes <= 20,
      RecipeTimeFilter.under30 => recipe.minutes <= 30,
      RecipeTimeFilter.over30 => recipe.minutes > 30,
    };
  }

  static List<_RecipeIndexEntry> _buildEntries(List<RecipeModel> recipes) {
    return [
      for (var index = 0; index < recipes.length; index++)
        _RecipeIndexEntry(recipe: recipes[index], sourceIndex: index),
    ];
  }

  static List<CategoryModel> _buildCategories(List<RecipeModel> recipes) {
    final countsByCategoryId = <String, int>{
      for (final category in CategoryCatalog.items) category.id: 0,
    };

    for (final recipe in recipes) {
      for (final categoryId in _categoryIdsForRecipe(recipe)) {
        countsByCategoryId[categoryId] =
            (countsByCategoryId[categoryId] ?? 0) + 1;
      }
    }

    return [
      for (final category in CategoryCatalog.items)
        category.copyWith(recipesCount: countsByCategoryId[category.id] ?? 0),
    ];
  }

  static Map<String, String> _buildTagLabels(List<RecipeModel> recipes) {
    final labelsById = <String, String>{};
    for (final recipe in recipes) {
      for (final tag in recipe.tags) {
        final tagId = CategoryCatalog.slug(tag);
        if (tagId.isEmpty) {
          continue;
        }
        labelsById.putIfAbsent(tagId, () => _readableSearchLabel(tag));
      }
    }
    return labelsById;
  }

  static Map<String, String> _buildAuthorNames(List<RecipeModel> recipes) {
    final namesById = <String, String>{};
    for (final recipe in recipes) {
      final authorId = CategoryCatalog.slug(recipe.author);
      if (authorId.isEmpty) {
        continue;
      }
      namesById.putIfAbsent(authorId, () => recipe.author);
    }
    return namesById;
  }

  static List<_TagSuggestionEntry> _buildTagSuggestions(
    List<RecipeModel> recipes,
  ) {
    final countsById = <String, int>{};
    final labelsById = <String, String>{};

    for (final recipe in recipes) {
      for (final tag in recipe.tags) {
        final tagId = CategoryCatalog.slug(tag);
        if (tagId.isEmpty) {
          continue;
        }
        labelsById.putIfAbsent(tagId, () => _readableSearchLabel(tag));
        countsById[tagId] = (countsById[tagId] ?? 0) + 1;
      }
    }

    return [
      for (final tagId in countsById.keys)
        _TagSuggestionEntry(
          id: tagId,
          label: labelsById[tagId]!,
          count: countsById[tagId]!,
        ),
    ];
  }

  static List<_AuthorSuggestionEntry> _buildAuthorSuggestions(
    List<RecipeModel> recipes,
  ) {
    final countsById = <String, int>{};
    final namesById = <String, String>{};

    for (final recipe in recipes) {
      final authorId = CategoryCatalog.slug(recipe.author);
      if (authorId.isEmpty) {
        continue;
      }
      namesById.putIfAbsent(authorId, () => recipe.author);
      countsById[authorId] = (countsById[authorId] ?? 0) + 1;
    }

    return [
      for (final authorId in countsById.keys)
        _AuthorSuggestionEntry(
          id: authorId,
          name: namesById[authorId]!,
          count: countsById[authorId]!,
        ),
    ];
  }

  static Set<String> _categoryIdsForRecipe(RecipeModel recipe) {
    final categoryIds = <String>{};
    for (final category in CategoryCatalog.items) {
      if (CategoryCatalog.recipeMatchesCategory(recipe, category)) {
        categoryIds.add(category.id);
      }
    }
    return categoryIds;
  }
}

class _RecipeIndexEntry {
  _RecipeIndexEntry({required this.recipe, required this.sourceIndex})
    : titleLower = recipe.title.toLowerCase(),
      titleSlug = CategoryCatalog.slug(recipe.title),
      authorId = CategoryCatalog.slug(recipe.author),
      categoryIds = RecipeQueryIndex._categoryIdsForRecipe(recipe),
      tagIds = {
        for (final tag in recipe.tags)
          if (CategoryCatalog.slug(tag).isNotEmpty) CategoryCatalog.slug(tag),
      },
      searchText = _searchTextFor(recipe),
      searchSlug = CategoryCatalog.slug(_searchTextFor(recipe));

  final RecipeModel recipe;
  final int sourceIndex;
  final String titleLower;
  final String titleSlug;
  final String authorId;
  final Set<String> categoryIds;
  final Set<String> tagIds;
  final String searchText;
  final String searchSlug;

  static String _searchTextFor(RecipeModel recipe) {
    final category = CategoryCatalog.findById(recipe.categoryId);
    final tagText = recipe.tags.expand(
      (tag) => [tag.toLowerCase(), _readableSearchLabel(tag).toLowerCase()],
    );

    return [
      recipe.title.toLowerCase(),
      recipe.categoryName.toLowerCase(),
      recipe.author.toLowerCase(),
      if (category != null) category.title.toLowerCase(),
      ...tagText,
    ].join(' ');
  }
}

class _TagSuggestionEntry {
  _TagSuggestionEntry({
    required this.id,
    required this.label,
    required this.count,
  }) : labelLower = label.toLowerCase();

  final String id;
  final String label;
  final String labelLower;
  final int count;
}

class _AuthorSuggestionEntry {
  _AuthorSuggestionEntry({
    required this.id,
    required this.name,
    required this.count,
  }) : nameLower = name.toLowerCase();

  final String id;
  final String name;
  final String nameLower;
  final int count;
}

String _readableSearchLabel(String value) {
  final words = value
      .trim()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);

  return words
      .map((word) {
        if (word.length == 1) {
          return word.toUpperCase();
        }

        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      })
      .join(' ');
}
