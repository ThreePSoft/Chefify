part of '../pages/recipe_create_page.dart';

class _RecipeEditorPalette extends StatelessWidget {
  const _RecipeEditorPalette({
    this.embedded = false,
    required this.activeTab,
    required this.templates,
    required this.blocks,
    required this.blockCueAnimation,
    required this.onTabChanged,
    required this.onTemplateSelected,
    required this.onBlockSelected,
  });

  final bool embedded;
  final _RecipeEditorTab activeTab;
  final List<_RecipeTemplateDefinition> templates;
  final List<_RecipeBlockDefinition> blocks;
  final Animation<double> blockCueAnimation;
  final ValueChanged<_RecipeEditorTab> onTabChanged;
  final ValueChanged<_RecipeTemplateDefinition> onTemplateSelected;
  final ValueChanged<_RecipeBlockDefinition> onBlockSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final content = activeTab == _RecipeEditorTab.templates
        ? _buildTemplateList(context)
        : _buildBlockList(context);

    return Container(
      padding: embedded ? EdgeInsets.zero : const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: embedded
            ? Colors.transparent
            : palette.cardsSurface.withValues(alpha: 0.72),
        borderRadius: embedded
            ? BorderRadius.zero
            : BorderRadius.circular(AppSpacing.radiusMd),
        border: embedded
            ? null
            : Border.all(color: palette.borders.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _RecipeEditorTabButton(
                  label: 'Templates',
                  selected: activeTab == _RecipeEditorTab.templates,
                  onPressed: () => onTabChanged(_RecipeEditorTab.templates),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _RecipeEditorTabButton(
                  label: 'Blocks',
                  selected: activeTab == _RecipeEditorTab.blocks,
                  onPressed: () => onTabChanged(_RecipeEditorTab.blocks),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          content,
        ],
      ),
    );
  }

  Widget _buildTemplateList(BuildContext context) {
    return Column(
      children: [
        for (final template in templates) ...[
          _RecipeTemplatePreviewTarget(
            key: ValueKey('expanded-template-${template.title}'),
            template: template,
            child: _RecipePaletteItem(
              icon: template.icon,
              title: template.title,
              description: template.description,
              onPressed: () => onTemplateSelected(template),
            ),
          ),
          if (template != templates.last) const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }

  Widget _buildBlockList(BuildContext context) {
    final groups = _RecipeBlockGroup.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          _RecipePaletteGroupTitle(group: group),
          const SizedBox(height: AppSpacing.xs),
          for (final block in blocks.where(
            (block) => block.kind.group == group,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _RecipePaletteBlockDragSource(
                block: block,
                child: _RecipePaletteItem(
                  icon: block.kind.icon,
                  title: block.kind.label,
                  description: block.description,
                  iconOpacity: blockCueAnimation,
                  onPressed: () => onBlockSelected(block),
                ),
              ),
            ),
          if (group != groups.last) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _RecipeEditorTabButton extends StatelessWidget {
  const _RecipeEditorTabButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: selected
          ? palette.primaryButtons.withValues(alpha: 0.22)
          : palette.searchBarBackground.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected ? palette.primaryButtons : palette.mainText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipePaletteGroupTitle extends StatelessWidget {
  const _RecipePaletteGroupTitle({required this.group});

  final _RecipeBlockGroup group;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = switch (group) {
      _RecipeBlockGroup.content => 'Content',
      _RecipeBlockGroup.recipe => 'Recipe',
      _RecipeBlockGroup.widgets => 'Widgets',
      _RecipeBlockGroup.layout => 'Layout',
    };

    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: palette.categoryTags,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _RecipePaletteItem extends StatelessWidget {
  const _RecipePaletteItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
    this.iconOpacity,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;
  final Animation<double>? iconOpacity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.searchBarBackground.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (iconOpacity case final animation?)
                FadeTransition(
                  opacity: animation,
                  child: Icon(icon, color: palette.primaryButtons, size: 20),
                )
              else
                Icon(icon, color: palette.primaryButtons, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.mainText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.secondaryText,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
