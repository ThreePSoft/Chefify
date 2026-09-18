part of '../pages/recipe_create_page.dart';

@immutable
class _RecipeBlockDefinition {
  const _RecipeBlockDefinition({required this.kind, required this.description});

  final _RecipeBlockKind kind;
  final String description;
}

@immutable
class _RecipeTemplateDefinition {
  const _RecipeTemplateDefinition({
    required this.title,
    required this.description,
    required this.icon,
    required this.createBlocks,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<_RecipeEditorBlock> Function(String Function(String prefix))
  createBlocks;
}
