import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/localization/app_strings.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/features/auth/presentation/auth_controller.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final strings = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontalPadding(context),
                  AppSpacing.xl,
                  AppSpacing.horizontalPadding(context),
                  AppSpacing.sectionGap,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: auth.user == null
                        ? _GuestProfile(strings: strings)
                        : _SignedInProfile(strings: strings),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        children: [
          const Icon(Icons.lock_person_rounded, size: 56),
          const SizedBox(height: AppSpacing.md),
          Text(
            strings.profileGuestTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              AppButton(
                label: strings.logIn,
                variant: AppButtonVariant.outlined,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.login),
              ),
              AppButton(
                label: strings.createAccount,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.register),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignedInProfile extends StatelessWidget {
  const _SignedInProfile({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final user = auth.user!;
    final palette = context.palette;
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: palette.primaryButtons,
                foregroundColor: Colors.white,
                child: Text(
                  user.initials,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      key: const ValueKey('profile-user-name'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            strings.accountDetails,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),
          _ProfileDetail(
            icon: Icons.mail_outline_rounded,
            label: strings.emailLabel,
            value: user.email,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: strings.memberRole,
            value: user.role,
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              key: const ValueKey('profile-sign-out'),
              label: strings.signOut,
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.outlined,
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: palette.cardsSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: palette.borders),
      ),
      child: child,
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Icon(icon, color: palette.icons),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: palette.secondaryText),
              ),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
