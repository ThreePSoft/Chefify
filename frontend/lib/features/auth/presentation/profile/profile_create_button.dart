part of '../pages/profile_page.dart';

class _ProfileCreateButton extends StatefulWidget {
  const _ProfileCreateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_ProfileCreateButton> createState() => _ProfileCreateButtonState();
}

class _ProfileCreateButtonState extends State<_ProfileCreateButton> {
  bool _hovered = false;
  bool _focused = false;

  bool get _expanded => _hovered || _focused;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = AppStrings.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: FocusableActionDetector(
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: Material(
          color: palette.primaryButtons,
          elevation: 8,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            key: const ValueKey('profile-create-recipe'),
            borderRadius: BorderRadius.circular(999),
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: _expanded ? 184 : 56,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.centerLeft,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white),
                  Positioned(
                    left: 32,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 130),
                      opacity: _expanded ? 1 : 0,
                      child: Text(
                        strings.createRecipe,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
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
    );
  }
}
