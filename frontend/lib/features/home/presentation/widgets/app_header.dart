import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/localization/app_strings.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/chefify_brand_mark.dart';
import 'package:frontend/features/auth/presentation/auth_controller.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = AppStrings.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.horizontalPadding(context),
        24,
        AppSpacing.horizontalPadding(context),
        10,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.contentMaxWidth,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = !AppSpacing.useDesktopNavigationForContent(
                constraints.maxWidth,
              );
              final actionGap = compact ? AppSpacing.xs : AppSpacing.md;
              final showSearchAction = constraints.maxWidth >= 360;
              final auth = AuthScope.maybeOf(context);

              return Row(
                children: [
                  const _Logo(),
                  SizedBox(width: actionGap),
                  if (!compact)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _DesktopHeaderActions(strings: strings),
                      ),
                    )
                  else ...[
                    const Spacer(),
                    if (showSearchAction)
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search_rounded),
                        color: palette.icons,
                      ),
                    IconButton(
                      tooltip: auth?.isAuthenticated == true
                          ? strings.profile
                          : strings.logIn,
                      onPressed: () => _openRoute(
                        context,
                        auth?.isAuthenticated == true
                            ? AppRouter.profile
                            : AppRouter.login,
                      ),
                      icon: auth?.isAuthenticated == true
                          ? const _ProfileMark(size: 34)
                          : const Icon(Icons.login_rounded),
                      color: auth?.isAuthenticated == true
                          ? null
                          : palette.icons,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.menu_rounded),
                      color: palette.icons,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DesktopHeaderActions extends StatelessWidget {
  const _DesktopHeaderActions({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.maybeOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _MainNavigation(),
        const SizedBox(width: AppSpacing.lg),
        if (auth?.isAuthenticated == true)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: _ProfileAction(
              name: auth!.user!.name,
              onPressed: () => _openRoute(context, AppRouter.profile),
            ),
          )
        else ...[
          AppButton(
            label: strings.logIn,
            variant: AppButtonVariant.ghost,
            onPressed: () => _openRoute(context, AppRouter.login),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            label: strings.getStarted,
            onPressed: () => _openRoute(context, AppRouter.register),
          ),
        ],
      ],
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({required this.name, required this.onPressed});

  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.primaryButtons,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        key: const ValueKey('header-profile-action'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _ProfileMark(size: 38),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMark extends StatelessWidget {
  const _ProfileMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('header-profile-mark'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.palette.primaryButtons,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.person_rounded, size: size * 0.58, color: Colors.white),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openRoute(context, AppRouter.home),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 148),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxs),
          child: Row(
            children: [
              const ChefifyBrandMark(),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  'Chefify',
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainNavigation extends StatelessWidget {
  const _MainNavigation();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = context.palette;
    final items = [
      _NavigationItem(label: strings.recipes, route: AppRouter.recipes),
      _NavigationItem(label: strings.mealPlans),
      _NavigationItem(label: strings.pricing),
      _NavigationItem(label: strings.community),
    ];
    return Row(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: TextButton(
              onPressed: item.route == null
                  ? () {}
                  : () => _openRoute(context, item.route!),
              style: TextButton.styleFrom(
                foregroundColor:
                    item.route != null && _isCurrentRoute(context, item.route!)
                    ? palette.primaryButtons
                    : palette.mainText,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(item.label),
            ),
          ),
      ],
    );
  }
}

class _NavigationItem {
  const _NavigationItem({required this.label, this.route});

  final String label;
  final String? route;
}

bool _isCurrentRoute(BuildContext context, String routeName) {
  return ModalRoute.of(context)?.settings.name == routeName;
}

void _openRoute(BuildContext context, String routeName) {
  if (_isCurrentRoute(context, routeName)) {
    return;
  }

  Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
}
