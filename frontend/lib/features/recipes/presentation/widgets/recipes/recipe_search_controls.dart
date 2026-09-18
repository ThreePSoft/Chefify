part of '../../pages/recipes_page.dart';

class _RecipeControls extends StatelessWidget {
  const _RecipeControls({
    required this.searchController,
    required this.selectedCategoryIds,
    required this.selectedTags,
    required this.selectedAuthors,
    required this.timeFilter,
    required this.sort,
    required this.savedOnly,
    required this.categories,
    required this.recipeIndex,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onTagSelected,
    required this.onTagRemoved,
    required this.onAuthorSelected,
    required this.onAuthorRemoved,
    required this.onCategoryToggled,
    required this.onClearCategories,
    required this.onTimeFilterChanged,
    required this.onSortChanged,
    required this.onSavedOnlyChanged,
  });

  final TextEditingController searchController;
  final Set<String> selectedCategoryIds;
  final List<RecipeSearchTagToken> selectedTags;
  final List<RecipeSearchAuthorToken> selectedAuthors;
  final RecipeTimeFilter timeFilter;
  final RecipeSort sort;
  final bool savedOnly;
  final List<CategoryModel> categories;
  final RecipeQueryIndex recipeIndex;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onTagSelected;
  final ValueChanged<String> onTagRemoved;
  final ValueChanged<String> onAuthorSelected;
  final ValueChanged<String> onAuthorRemoved;
  final ValueChanged<String> onCategoryToggled;
  final VoidCallback onClearCategories;
  final ValueChanged<RecipeTimeFilter> onTimeFilterChanged;
  final ValueChanged<RecipeSort> onSortChanged;
  final ValueChanged<bool> onSavedOnlyChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;
          final search = _RecipeSearchBox(
            controller: searchController,
            selectedTags: selectedTags,
            selectedAuthors: selectedAuthors,
            recipeIndex: recipeIndex,
            onChanged: onSearchChanged,
            onClearSearch: onClearSearch,
            onTagSelected: onTagSelected,
            onTagRemoved: onTagRemoved,
            onAuthorSelected: onAuthorSelected,
            onAuthorRemoved: onAuthorRemoved,
          );
          final sortPicker = _SortDropdown(
            sort: sort,
            onChanged: onSortChanged,
          );
          final savedButton = _SavedOnlyButton(
            selected: savedOnly,
            onChanged: onSavedOnlyChanged,
          );
          final sideControlWidth = constraints.maxWidth < 1040 ? 184.0 : 204.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    search,
                    const SizedBox(height: AppSpacing.sm),
                    if (constraints.maxWidth < 520)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          sortPicker,
                          const SizedBox(height: AppSpacing.sm),
                          savedButton,
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(child: sortPicker),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: savedButton),
                        ],
                      ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(flex: 3, child: search),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(width: sideControlWidth, child: sortPicker),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(width: sideControlWidth, child: savedButton),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Categories',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (selectedCategoryIds.isNotEmpty)
                    TextButton(
                      onPressed: onClearCategories,
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              _CategoryFilterCloud(
                categories: categories,
                selectedCategoryIds: selectedCategoryIds,
                onCategoryToggled: onCategoryToggled,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Cook time', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _RecipeTimeFilterChip(
                    label: 'Any',
                    filter: RecipeTimeFilter.any,
                    selectedFilter: timeFilter,
                    onSelected: onTimeFilterChanged,
                  ),
                  _RecipeTimeFilterChip(
                    label: '20 min or less',
                    filter: RecipeTimeFilter.under20,
                    selectedFilter: timeFilter,
                    onSelected: onTimeFilterChanged,
                  ),
                  _RecipeTimeFilterChip(
                    label: '30 min or less',
                    filter: RecipeTimeFilter.under30,
                    selectedFilter: timeFilter,
                    onSelected: onTimeFilterChanged,
                  ),
                  _RecipeTimeFilterChip(
                    label: 'Over 30 min',
                    filter: RecipeTimeFilter.over30,
                    selectedFilter: timeFilter,
                    onSelected: onTimeFilterChanged,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecipeSearchBox extends StatefulWidget {
  const _RecipeSearchBox({
    required this.controller,
    required this.selectedTags,
    required this.selectedAuthors,
    required this.recipeIndex,
    required this.onChanged,
    required this.onClearSearch,
    required this.onTagSelected,
    required this.onTagRemoved,
    required this.onAuthorSelected,
    required this.onAuthorRemoved,
  });

  final TextEditingController controller;
  final List<RecipeSearchTagToken> selectedTags;
  final List<RecipeSearchAuthorToken> selectedAuthors;
  final RecipeQueryIndex recipeIndex;
  final ValueChanged<String> onChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onTagSelected;
  final ValueChanged<String> onTagRemoved;
  final ValueChanged<String> onAuthorSelected;
  final ValueChanged<String> onAuthorRemoved;

  @override
  State<_RecipeSearchBox> createState() => _RecipeSearchBoxState();
}

class _RecipeSearchBoxState extends State<_RecipeSearchBox> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _chipsScrollController = ScrollController();
  final LayerLink _suggestionsLayerLink = LayerLink();
  final GlobalKey _searchBoxKey = GlobalKey();
  OverlayEntry? _suggestionsOverlay;
  Timer? _changeDebounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant _RecipeSearchBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncSuggestionsOverlay();
      }
    });
  }

  @override
  void dispose() {
    _changeDebounce?.cancel();
    _removeSuggestionsOverlay();
    widget.controller.removeListener(_handleControllerChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    _chipsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final focused = _focusNode.hasFocus;
    final hasQuery = widget.controller.text.trim().isNotEmpty;
    final hasActiveSearch =
        hasQuery ||
        widget.selectedTags.isNotEmpty ||
        widget.selectedAuthors.isNotEmpty;
    final borderColor = focused ? palette.activeElements : palette.borders;

    return LayoutBuilder(
      builder: (context, constraints) {
        final inputWidth = (constraints.maxWidth * 0.48)
            .clamp(160.0, 360.0)
            .toDouble();

        return CompositedTransformTarget(
          link: _suggestionsLayerLink,
          child: GestureDetector(
            key: _searchBoxKey,
            behavior: HitTestBehavior.opaque,
            onTap: () => _focusNode.requestFocus(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: palette.searchBarBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 21, color: palette.icons),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        controller: _chipsScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final author in widget.selectedAuthors) ...[
                              _AuthorSearchTokenChip(
                                author: author,
                                onRemoved: widget.onAuthorRemoved,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                            for (final tag in widget.selectedTags) ...[
                              _TagSearchTokenChip(
                                tag: tag,
                                onRemoved: widget.onTagRemoved,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                            SizedBox(
                              width: inputWidth,
                              child: TextField(
                                key: const ValueKey('recipes-search-field'),
                                focusNode: _focusNode,
                                controller: widget.controller,
                                onChanged: _handleSearchChanged,
                                textInputAction: TextInputAction.search,
                                style: Theme.of(context).textTheme.bodyMedium,
                                decoration: InputDecoration(
                                  hintText:
                                      widget.selectedAuthors.isEmpty &&
                                          widget.selectedTags.isEmpty
                                      ? 'Search recipes'
                                      : '',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (hasActiveSearch)
                    IconButton(
                      tooltip: 'Clear search',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleFocusChanged() {
    setState(() {});
    _syncSuggestionsOverlay();
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
    _syncSuggestionsOverlay();
  }

  void _handleSearchChanged(String value) {
    _changeDebounce?.cancel();
    _changeDebounce = Timer(const Duration(milliseconds: 120), () {
      if (mounted) {
        widget.onChanged(value);
      }
    });
  }

  void _clearSearch() {
    _changeDebounce?.cancel();
    widget.onClearSearch();
  }

  void _syncSuggestionsOverlay() {
    if (!_focusNode.hasFocus || _suggestions().isEmpty) {
      _removeSuggestionsOverlay();
      return;
    }

    _showSuggestionsOverlay();
  }

  void _showSuggestionsOverlay() {
    if (_suggestionsOverlay != null) {
      _suggestionsOverlay!.markNeedsBuild();
      return;
    }

    _suggestionsOverlay = OverlayEntry(
      builder: (overlayContext) {
        final suggestions = _focusNode.hasFocus
            ? _suggestions()
            : const <RecipeSearchSuggestion>[];
        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        return CompositedTransformFollower(
          link: _suggestionsLayerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, AppSpacing.xs),
          showWhenUnlinked: false,
          child: Material(
            type: MaterialType.transparency,
            child: Align(
              alignment: Alignment.topLeft,
              widthFactor: 1,
              heightFactor: 1,
              child: SizedBox(
                width: _searchBoxWidth(),
                child: _RecipeSearchSuggestionsPanel(
                  suggestions: suggestions,
                  onSelected: _selectSuggestion,
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_suggestionsOverlay!);
  }

  void _removeSuggestionsOverlay() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }

  double _searchBoxWidth() {
    final renderObject = _searchBoxKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.size.width;
    }

    return 320;
  }

  List<RecipeSearchSuggestion> _suggestions() {
    return widget.recipeIndex.suggestions(
      query: widget.controller.text,
      selectedTagIds: {for (final tag in widget.selectedTags) tag.id},
      selectedAuthorIds: {
        for (final author in widget.selectedAuthors) author.id,
      },
    );
  }

  void _selectSuggestion(RecipeSearchSuggestion suggestion) {
    _changeDebounce?.cancel();
    _removeSuggestionsOverlay();

    switch (suggestion.type) {
      case RecipeSearchSuggestionType.recipe:
        widget.controller.value = TextEditingValue(
          text: suggestion.value,
          selection: TextSelection.collapsed(offset: suggestion.value.length),
        );
        widget.onChanged(suggestion.value);
      case RecipeSearchSuggestionType.tag:
        widget.onTagSelected(suggestion.value);
      case RecipeSearchSuggestionType.author:
        widget.onAuthorSelected(suggestion.value);
    }

    _focusNode.requestFocus();
  }
}

class _RecipeSearchSuggestionsPanel extends StatelessWidget {
  const _RecipeSearchSuggestionsPanel({
    required this.suggestions,
    required this.onSelected,
  });

  final List<RecipeSearchSuggestion> suggestions;
  final ValueChanged<RecipeSearchSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 292),
      child: Container(
        decoration: BoxDecoration(
          color: palette.cardsSurface.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: palette.borders.withValues(alpha: 0.76)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < suggestions.length; index++)
                _RecipeSearchSuggestionTile(
                  suggestion: suggestions[index],
                  showDivider: index < suggestions.length - 1,
                  onSelected: onSelected,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeSearchSuggestionTile extends StatelessWidget {
  const _RecipeSearchSuggestionTile({
    required this.suggestion,
    required this.showDivider,
    required this.onSelected,
  });

  final RecipeSearchSuggestion suggestion;
  final bool showDivider;
  final ValueChanged<RecipeSearchSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final trailingLabel = suggestion.trailingLabel;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: showDivider
              ? BorderSide(color: palette.borders.withValues(alpha: 0.42))
              : BorderSide.none,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey(
            'recipe-search-suggestion-${suggestion.type.name}-${CategoryCatalog.slug(suggestion.value)}',
          ),
          onTapDown: (_) => onSelected(suggestion),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (trailingLabel != null && trailingLabel.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _SuggestionTypeBadge(label: trailingLabel),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionTypeBadge extends StatelessWidget {
  const _SuggestionTypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: palette.primaryButtons.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: palette.primaryButtons,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TagSearchTokenChip extends StatelessWidget {
  const _TagSearchTokenChip({required this.tag, required this.onRemoved});

  final RecipeSearchTagToken tag;
  final ValueChanged<String> onRemoved;

  @override
  Widget build(BuildContext context) {
    return _SearchTokenShell(
      key: ValueKey('recipe-search-tag-token-${tag.id}'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag.label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: AppSpacing.xxs),
          _SearchTokenRemoveButton(onPressed: () => onRemoved(tag.id)),
        ],
      ),
    );
  }
}

class _AuthorSearchTokenChip extends StatelessWidget {
  const _AuthorSearchTokenChip({required this.author, required this.onRemoved});

  final RecipeSearchAuthorToken author;
  final ValueChanged<String> onRemoved;

  @override
  Widget build(BuildContext context) {
    return _SearchTokenShell(
      key: ValueKey('recipe-search-author-token-${author.id}'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SearchAuthorAvatar(authorName: author.name),
          const SizedBox(width: AppSpacing.xs),
          Text(author.name, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: AppSpacing.xxs),
          _SearchTokenRemoveButton(onPressed: () => onRemoved(author.id)),
        ],
      ),
    );
  }
}

class _SearchTokenShell extends StatelessWidget {
  const _SearchTokenShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 34,
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: palette.cardsSurface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borders.withValues(alpha: 0.84)),
      ),
      child: Center(child: child),
    );
  }
}

class _SearchTokenRemoveButton extends StatelessWidget {
  const _SearchTokenRemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: IconButton(
        tooltip: 'Remove filter',
        onPressed: onPressed,
        icon: const Icon(Icons.close_rounded, size: 15),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _SearchAuthorAvatar extends StatelessWidget {
  const _SearchAuthorAvatar({required this.authorName});

  final String authorName;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.primaryButtons.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.32),
        ),
      ),
      child: Text(
        _initials(authorName),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: palette.primaryButtons,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _initials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  if (words.isEmpty) {
    return '?';
  }

  if (words.length == 1) {
    return words.first[0].toUpperCase();
  }

  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}
