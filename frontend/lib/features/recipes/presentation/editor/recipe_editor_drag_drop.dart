part of '../pages/recipe_create_page.dart';

@immutable
abstract class _RecipeEditorDragData {
  const _RecipeEditorDragData();
}

@immutable
class _RecipeBlockDragData extends _RecipeEditorDragData {
  const _RecipeBlockDragData({
    required this.blockId,
    required this.sourceParentId,
    required this.sourceIndex,
    required this.sourceDepth,
  }) : super();

  final String blockId;
  final String? sourceParentId;
  final int sourceIndex;
  final int sourceDepth;
}

@immutable
class _RecipePaletteBlockDragData extends _RecipeEditorDragData {
  const _RecipePaletteBlockDragData(this.block);

  final _RecipeBlockDefinition block;
}

@immutable
class _RecipeBlockDropTarget {
  const _RecipeBlockDropTarget({
    required this.parentId,
    required this.index,
    required this.depth,
  });

  final String? parentId;
  final int index;
  final int depth;
}

@immutable
class _RecipeBlockLocation {
  const _RecipeBlockLocation({
    required this.block,
    required this.parentId,
    required this.index,
    required this.depth,
  });

  final _RecipeEditorBlock block;
  final String? parentId;
  final int index;
  final int depth;
}

@immutable
class _RecipeBlockExtraction {
  const _RecipeBlockExtraction({required this.blocks, this.block});

  final List<_RecipeEditorBlock> blocks;
  final _RecipeEditorBlock? block;
}

class _RecipeBlockHoverController {
  final Map<String, ValueNotifier<bool>> _blockStates = {};
  String? _activeBlockId;

  ValueNotifier<bool> listenableFor(String blockId) {
    return _blockStates.putIfAbsent(blockId, () => ValueNotifier(false));
  }

  void activate(String? blockId) {
    if (_activeBlockId == blockId) {
      return;
    }

    final previousId = _activeBlockId;
    _activeBlockId = blockId;
    if (previousId != null) {
      _blockStates[previousId]?.value = false;
    }
    if (blockId != null) {
      listenableFor(blockId).value = true;
    }
  }

  void dispose() {
    for (final state in _blockStates.values) {
      state.dispose();
    }
    _blockStates.clear();
  }
}
