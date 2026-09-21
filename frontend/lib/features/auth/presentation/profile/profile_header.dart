part of '../pages/profile_page.dart';

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.recipeCount,
    required this.favoriteCount,
    required this.onEdit,
  });

  final AuthUser user;
  final int recipeCount;
  final int favoriteCount;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = AppStrings.of(context);
    return AppCard(
      key: const ValueKey('profile-header'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Stack(
        children: [
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 82,
                height: 82,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.primaryButtons,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  user.initials,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 220),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      key: const ValueKey('profile-user-name'),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _ProfileStat(
                          icon: Icons.restaurant_menu_rounded,
                          value: recipeCount,
                          label: strings.myRecipes,
                        ),
                        _ProfileStat(
                          icon: Icons.favorite_rounded,
                          value: favoriteCount,
                          label: strings.favoriteRecipes,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: IconButton.filledTonal(
              key: const ValueKey('profile-edit-action'),
              tooltip: strings.editProfile,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.searchBarBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: palette.icons),
          const SizedBox(width: AppSpacing.xs),
          Text('$value $label'),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.user});

  final AuthUser user;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.user.name,
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isValid = _nameController.text.trim().length >= 3;
    return AlertDialog(
      title: Text(strings.editProfile),
      content: TextField(
        key: const ValueKey('profile-name-field'),
        controller: _nameController,
        autofocus: true,
        maxLength: 50,
        decoration: InputDecoration(labelText: strings.nameLabel),
        onChanged: (_) => setState(() {}),
        onSubmitted: isValid
            ? (_) => Navigator.of(context).pop(_nameController.text.trim())
            : null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
        FilledButton(
          key: const ValueKey('profile-save-action'),
          onPressed: isValid
              ? () => Navigator.of(context).pop(_nameController.text.trim())
              : null,
          child: Text(strings.saveChanges),
        ),
      ],
    );
  }
}
