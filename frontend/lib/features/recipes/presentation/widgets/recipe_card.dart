import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/images/optimized_network_image.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/features/recipes/domain/recipes_page_arguments.dart';
import 'package:frontend/shared/bookmarks/bookmark_button.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

part 'recipe_card/recipe_card_author.dart';
part 'recipe_card/recipe_card_formatters.dart';
part 'recipe_card/recipe_card_image.dart';
part 'recipe_card/recipe_card_tags.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, this.onTap});

  final RecipeModel recipe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hasFixedHeight =
                  constraints.hasBoundedHeight &&
                  constraints.minHeight == constraints.maxHeight;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 162,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_recipePreviewImageUrl(recipe) == null)
                          _RecipeImageFallback(recipe: recipe)
                        else
                          _RecipeNetworkImage(recipe: recipe),
                        Positioned(
                          top: AppSpacing.sm,
                          left: AppSpacing.sm,
                          child: _RecipeAuthorChip(
                            recipe: recipe,
                            maxExpandedWidth: _authorChipMaxWidth(
                              constraints.maxWidth,
                            ),
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: _RecipeBookmarkButton(recipe: recipe),
                        ),
                      ],
                    ),
                  ),
                  if (hasFixedHeight)
                    Expanded(
                      child: _RecipeCardBody(recipe: recipe, pinFooter: true),
                    )
                  else
                    _RecipeCardBody(recipe: recipe, pinFooter: false),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RecipeBookmarkButton extends StatelessWidget {
  const _RecipeBookmarkButton({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    final bookmarks = BookmarkScope.of(context);
    final isSaved = bookmarks.isRecipeSaved(recipe);

    return BookmarkButton(
      isSaved: isSaved,
      onPressed: () {
        bookmarks.toggleRecipe(recipe);
      },
    );
  }
}

class _RecipeCardBody extends StatelessWidget {
  const _RecipeCardBody({required this.recipe, required this.pinFooter});

  final RecipeModel recipe;
  final bool pinFooter;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: pinFooter ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.categoryName,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: palette.categoryTags),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            recipe.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (pinFooter) const Spacer(),
          if (recipe.tags.isNotEmpty) ...[
            _RecipeTagRow(recipeId: recipe.id, tags: recipe.tags),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: palette.icons),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${recipe.minutes} min',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Icon(Icons.star_rounded, size: 18, color: palette.activeElements),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                recipe.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
