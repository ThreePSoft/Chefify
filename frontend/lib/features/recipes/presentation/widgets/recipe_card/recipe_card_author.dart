part of '../recipe_card.dart';

class _RecipeAuthorChip extends StatefulWidget {
  const _RecipeAuthorChip({
    required this.recipe,
    required this.maxExpandedWidth,
  });

  final RecipeModel recipe;
  final double maxExpandedWidth;

  @override
  State<_RecipeAuthorChip> createState() => _RecipeAuthorChipState();
}

class _RecipeAuthorChipState extends State<_RecipeAuthorChip> {
  bool _hovered = false;
  bool _focused = false;

  bool get _expanded => _hovered || _focused;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final expandedWidth = widget.maxExpandedWidth.clamp(44.0, 164.0);
    final width = _expanded ? expandedWidth : 44.0;
    final foregroundColor = palette.mainText;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: FocusableActionDetector(
        onFocusChange: (focused) {
          setState(() {
            _focused = focused;
          });
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('recipe-author-chip-${widget.recipe.id}'),
            onTap: () {
              final auth = AuthScope.maybeOf(context);
              final isOwnProfile =
                  auth?.isAuthenticated == true &&
                  createSlug(auth!.user!.name) ==
                      createSlug(widget.recipe.author);
              Navigator.of(context).pushNamed(
                isOwnProfile
                    ? AppRouter.profile
                    : AppRouter.authorProfilePath(widget.recipe.author),
                arguments: isOwnProfile ? null : widget.recipe.author,
              );
            },
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: width,
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: palette.cardsSurface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: palette.borders.withValues(alpha: 0.84),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RecipeAuthorAvatar(author: widget.recipe.author),
                    Flexible(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 130),
                        curve: Curves.easeOut,
                        opacity: _expanded ? 1 : 0,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.xs,
                            right: AppSpacing.xs,
                          ),
                          child: Text(
                            widget.recipe.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: foregroundColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeAuthorAvatar extends StatelessWidget {
  const _RecipeAuthorAvatar({required this.author});

  final String author;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.primaryButtons.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: palette.primaryButtons.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        _authorInitials(author),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: palette.primaryButtons,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
