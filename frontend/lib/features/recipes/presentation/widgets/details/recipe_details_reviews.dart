part of '../../pages/recipe_details_page.dart';

class _RecipeReviewsSection extends StatefulWidget {
  const _RecipeReviewsSection({
    required this.recipe,
    required this.reviews,
    required this.onReviewSubmitted,
  });

  final RecipeModel recipe;
  final List<RecipeReview> reviews;
  final void Function(int rating, String comment) onReviewSubmitted;

  @override
  State<_RecipeReviewsSection> createState() => _RecipeReviewsSectionState();
}

class _RecipeReviewsSectionState extends State<_RecipeReviewsSection> {
  static const int _reviewsPerPage = 20;

  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pageCount = (widget.reviews.length / _reviewsPerPage)
        .ceil()
        .clamp(1, 999)
        .toInt();
    final currentPageIndex = _pageIndex.clamp(0, pageCount - 1).toInt();
    final startIndex = currentPageIndex * _reviewsPerPage;
    final endIndex = (startIndex + _reviewsPerPage)
        .clamp(0, widget.reviews.length)
        .toInt();
    final pageReviews = widget.reviews
        .skip(startIndex)
        .take(_reviewsPerPage)
        .toList(growable: false);

    return AppCard(
      key: ValueKey('recipe-reviews-section-${widget.recipe.id}'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(context).reviews,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: palette.categoryTags,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.of(context).communityRating,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.of(context).reviewsCount(widget.reviews.length),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          _RecipeReviewComposer(onSubmitted: widget.onReviewSubmitted),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppStrings.of(
              context,
            ).reviewRange(startIndex + 1, endIndex, widget.reviews.length),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _RecipeReviewList(reviews: pageReviews),
          if (pageCount > 1) ...[
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: _RecipeReviewsPagination(
                pageCount: pageCount,
                pageIndex: currentPageIndex,
                onChanged: (pageIndex) {
                  setState(() {
                    _pageIndex = pageIndex;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipeReviewsPagination extends StatelessWidget {
  const _RecipeReviewsPagination({
    required this.pageCount,
    required this.pageIndex,
    required this.onChanged,
  });

  final int pageCount;
  final int pageIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        IconButton(
          tooltip: AppStrings.of(context).previousReviewPage,
          onPressed: pageIndex > 0 ? () => onChanged(pageIndex - 1) : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        for (var index = 0; index < pageCount; index++)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index == pageIndex
                      ? palette.primaryButtons
                      : palette.searchBarBackground.withValues(alpha: 0.76),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: index == pageIndex
                        ? palette.primaryButtons
                        : palette.borders.withValues(alpha: 0.72),
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: index == pageIndex ? Colors.white : palette.mainText,
                  ),
                ),
              ),
            ),
          ),
        IconButton(
          tooltip: AppStrings.of(context).nextReviewPage,
          onPressed: pageIndex < pageCount - 1
              ? () => onChanged(pageIndex + 1)
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _RecipeReviewList extends StatelessWidget {
  const _RecipeReviewList({required this.reviews});

  final List<RecipeReview> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < reviews.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.sm),
          _RecipeReviewCard(review: reviews[index]),
        ],
      ],
    );
  }
}

class _RecipeReviewCard extends StatelessWidget {
  const _RecipeReviewCard({required this.review});

  final RecipeReview review;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      key: ValueKey('recipe-review-card-${review.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.cardsSurface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: palette.borders.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecipeReviewAvatar(author: review.author),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      _formatReviewDateTime(review.createdAt),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _RecipeReviewStars(rating: review.rating),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(review.comment, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _RecipeReviewAvatar extends StatelessWidget {
  const _RecipeReviewAvatar({required this.author});

  final String author;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.primaryButtons.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        _initials(author),
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: palette.primaryButtons),
      ),
    );
  }
}

class _RecipeReviewStars extends StatelessWidget {
  const _RecipeReviewStars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var value = 1; value <= 5; value++)
          Icon(
            value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: 18,
            color: value <= rating
                ? const Color(0xFFE5A03C)
                : palette.secondaryText,
          ),
      ],
    );
  }
}

class _RecipeReviewComposer extends StatefulWidget {
  const _RecipeReviewComposer({required this.onSubmitted});

  final void Function(int rating, String comment) onSubmitted;

  @override
  State<_RecipeReviewComposer> createState() => _RecipeReviewComposerState();
}

class _RecipeReviewComposerState extends State<_RecipeReviewComposer> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final canSubmit = _commentController.text.trim().isNotEmpty;
    final ratingLabel = Text(
      AppStrings.of(context).leaveReview,
      style: Theme.of(context).textTheme.titleMedium,
    );
    final ratingPicker = _RecipeReviewRatingPicker(
      rating: _rating,
      onChanged: (rating) {
        setState(() {
          _rating = rating;
        });
      },
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.searchBarBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: palette.borders.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 320) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ratingLabel,
                      const SizedBox(height: AppSpacing.xs),
                      ratingPicker,
                    ],
                  );
                }

                return Row(
                  children: [ratingLabel, const Spacer(), ratingPicker],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Stack(
            children: [
              TextField(
                key: const ValueKey('recipe-review-comment-field'),
                controller: _commentController,
                minLines: 4,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: AppStrings.of(context).reviewHint,
                  fillColor: palette.searchBarBackground.withValues(
                    alpha: 0.74,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    84,
                    68,
                  ),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
              Positioned(
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: IconButton.filled(
                  key: const ValueKey('recipe-review-submit-button'),
                  tooltip: AppStrings.of(context).postReview,
                  onPressed: canSubmit ? _submit : null,
                  iconSize: 24,
                  style: IconButton.styleFrom(
                    fixedSize: const Size.square(52),
                    backgroundColor: palette.primaryButtons,
                    disabledBackgroundColor: palette.borders.withValues(
                      alpha: 0.48,
                    ),
                    foregroundColor: palette.pageBackground,
                    disabledForegroundColor: palette.secondaryText.withValues(
                      alpha: 0.74,
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      return;
    }

    widget.onSubmitted(_rating, comment);
    _commentController.clear();
    setState(() {
      _rating = 5;
    });
  }
}

class _RecipeReviewRatingPicker extends StatelessWidget {
  const _RecipeReviewRatingPicker({
    required this.rating,
    required this.onChanged,
  });

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var value = 1; value <= 5; value++)
          Tooltip(
            message: AppStrings.of(context).starRating(value),
            child: Semantics(
              button: true,
              label: AppStrings.of(context).starRating(value),
              child: InkResponse(
                key: ValueKey('recipe-review-rating-$value'),
                onTap: () => onChanged(value),
                radius: 18,
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    value <= rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: value <= rating
                        ? const Color(0xFFE5A03C)
                        : palette.secondaryText,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
