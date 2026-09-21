part of '../pages/profile_page.dart';

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.selected, required this.onSelected});

  final _ProfileTab selected;
  final ValueChanged<_ProfileTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return SegmentedButton<_ProfileTab>(
      key: const ValueKey('profile-tabs'),
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: _ProfileTab.recipes,
          icon: const Icon(Icons.restaurant_menu_rounded),
          label: Text(strings.myRecipes),
        ),
        ButtonSegment(
          value: _ProfileTab.favorites,
          icon: const Icon(Icons.favorite_rounded),
          label: Text(strings.favoriteRecipes),
        ),
        ButtonSegment(
          value: _ProfileTab.settings,
          icon: const Icon(Icons.settings_rounded),
          label: Text(strings.settings),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onSelected(selection.first),
    );
  }
}
