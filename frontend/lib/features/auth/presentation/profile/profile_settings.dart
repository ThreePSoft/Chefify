part of '../pages/profile_page.dart';

class _ProfileSettings extends StatelessWidget {
  const _ProfileSettings({
    required this.user,
    required this.onEditProfile,
    required this.onSignOut,
  });

  final AuthUser user;
  final VoidCallback onEditProfile;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final strings = AppStrings.of(context);
    return AppCard(
      key: const ValueKey('profile-settings-panel'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.accountDetails,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsRow(
            icon: Icons.mail_outline_rounded,
            label: strings.emailLabel,
            value: user.email,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsRow(
            icon: Icons.badge_outlined,
            label: strings.memberRole,
            value: user.role,
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: strings.editProfile,
              icon: Icons.edit_rounded,
              variant: AppButtonVariant.outlined,
              onPressed: onEditProfile,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            strings.appearance,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(strings.profileDarkTheme),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (enabled) => settings.setThemeMode(
              enabled ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<AppLanguage>(
            initialValue: settings.language,
            decoration: InputDecoration(labelText: strings.profileLanguage),
            items: [
              for (final language in AppLanguage.values)
                DropdownMenuItem(value: language, child: Text(language.label)),
            ],
            onChanged: (language) {
              if (language != null) settings.setLanguage(language);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              key: const ValueKey('profile-sign-out'),
              label: strings.signOut,
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.outlined,
              onPressed: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
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
