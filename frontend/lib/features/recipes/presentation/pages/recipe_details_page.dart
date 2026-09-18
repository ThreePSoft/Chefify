import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/images/optimized_network_image.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/features/categories/data/category_catalog.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/features/recipes/presentation/controllers/recipe_details_controller.dart';
import 'package:frontend/features/recipes/presentation/widgets/recipe_collection_states.dart';
import 'package:frontend/shared/bookmarks/bookmark_button.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

part '../widgets/details/recipe_details_formatters.dart';
part '../widgets/details/recipe_details_hero.dart';
part '../widgets/details/recipe_details_overview.dart';
part '../widgets/details/recipe_details_reviews.dart';
part '../widgets/details/recipe_details_shell.dart';

class RecipeDetailsPageArguments {
  const RecipeDetailsPageArguments({
    required this.recipeId,
    this.initialRecipe,
  });

  factory RecipeDetailsPageArguments.from(
    Object? arguments, {
    required String fallbackRecipeId,
  }) {
    if (arguments is RecipeDetailsPageArguments) {
      return arguments;
    }

    if (arguments is RecipeModel) {
      return RecipeDetailsPageArguments(
        recipeId: arguments.id,
        initialRecipe: arguments,
      );
    }

    if (arguments is String && arguments.trim().isNotEmpty) {
      return RecipeDetailsPageArguments(recipeId: arguments.trim());
    }

    return RecipeDetailsPageArguments(recipeId: fallbackRecipeId);
  }

  final String recipeId;
  final RecipeModel? initialRecipe;
}

class RecipeDetailsPage extends StatefulWidget {
  const RecipeDetailsPage({
    super.key,
    required this.recipeId,
    this.initialRecipe,
    this.recipeRepository = const ApiRecipeRepository(),
  });

  final String recipeId;
  final RecipeModel? initialRecipe;
  final RecipeRepository recipeRepository;

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late final RecipeDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RecipeDetailsController(
      repository: widget.recipeRepository,
      recipeId: widget.recipeId,
      initialRecipe: widget.initialRecipe,
    )..addListener(_handleControllerChanged);
    if (widget.initialRecipe == null) {
      unawaited(_controller.load());
    }
  }

  @override
  void didUpdateWidget(covariant RecipeDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeId != widget.recipeId ||
        oldWidget.recipeRepository != widget.recipeRepository ||
        oldWidget.initialRecipe != widget.initialRecipe) {
      _controller.update(
        repository: widget.recipeRepository,
        recipeId: widget.recipeId,
        initialRecipe: widget.initialRecipe,
      );
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
    final bottomPadding = AppSpacing.sectionGapForWidth(viewportWidth);
    final horizontalPadding = AppSpacing.horizontalPaddingForWidth(
      viewportWidth,
    );
    final recipe = _controller.recipe;

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
              slivers: [
                _RecipeDetailsContentSliver(
                  topPadding: headerHeight + AppSpacing.xl,
                  bottomPadding: bottomPadding,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _controller.isLoading && recipe == null
                        ? const RecipeCollectionLoading()
                        : _controller.hasError && recipe == null
                        ? RecipeCollectionError(
                            error: _controller.error,
                            onRetry: () => unawaited(_controller.load()),
                          )
                        : recipe == null
                        ? _RecipeNotFound(recipeId: widget.recipeId)
                        : _RecipeDetailsContent(
                            recipe: recipe,
                            likesCount: _controller.likesCount,
                            reviews: _controller.reviews,
                            onReviewSubmitted: (rating, comment) {
                              _controller.addReview(
                                rating: rating,
                                comment: comment,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
            _RecipeDetailsHeaderShell(
              height: headerHeight,
              child: const AppHeader(),
            ),
            if (recipe != null)
              Positioned(
                left: horizontalPadding,
                top: headerHeight + AppSpacing.md,
                child: _RecipeStickyActionButton(
                  icon: _controller.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  tooltip: _controller.isLiked
                      ? 'Remove recipe like'
                      : 'Like recipe',
                  isActive: _controller.isLiked,
                  onPressed: () => unawaited(_toggleRecipeLike()),
                ),
              ),
            if (recipe != null)
              Positioned(
                right: horizontalPadding,
                bottom: AppSpacing.lg,
                child: _RecipeStickyActionButton(
                  icon: Icons.edit_rounded,
                  tooltip: 'Edit recipe',
                  onPressed: () {},
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRecipeLike() async {
    final wasSaved = await _controller.toggleLike();
    if (!mounted || wasSaved) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Could not update the recipe like. Please retry.'),
        ),
      );
  }
}
