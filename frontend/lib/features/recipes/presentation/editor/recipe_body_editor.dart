part of '../pages/recipe_create_page.dart';

class _RecipeBodyEditor extends StatefulWidget {
  const _RecipeBodyEditor({required this.scrollController});

  final ScrollController scrollController;

  @override
  State<_RecipeBodyEditor> createState() => _RecipeBodyEditorState();
}

class _RecipeBodyEditorState extends State<_RecipeBodyEditor> {
  static const int _maxDepth = 4;

  final OverlayPortalController _overlayController = OverlayPortalController();
  final _RecipeBlockHoverController _hoveredBlockId =
      _RecipeBlockHoverController();
  int _nextId = 0;
  _RecipeEditorTab _activeTab = _RecipeEditorTab.templates;
  bool _paletteExpanded = false;
  bool _inspectorExpanded = false;
  bool _appendNextBlock = false;
  int _blockPaletteCue = 0;
  String? _selectedBlockId;
  late List<_RecipeEditorBlock> _blocks = _initialBlocks();

  late final List<_RecipeBlockDefinition> _blockDefinitions = [
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.heading,
      description: 'Section title with strong hierarchy.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.paragraph,
      description: 'Body copy for preparation details.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.quote,
      description: 'Call out a chef note or personal tip.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.image,
      description: 'Add a supporting process photo.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.video,
      description: 'Embed a short cooking clip.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.note,
      description: 'Highlight timing, texture, or storage advice.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.divider,
      description: 'Separate two parts of the recipe.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.ingredients,
      description: 'Structured ingredient checklist.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.steps,
      description: 'Ordered cooking instructions.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.equipment,
      description: 'Tools and cookware required.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.substitutions,
      description: 'Alternative ingredients or swaps.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.nutrition,
      description: 'Nutrition facts summary.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.timer,
      description: 'Inline timer for a cooking step.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.servings,
      description: 'Scale ingredient amounts by servings.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.checklist,
      description: 'Track prep tasks before cooking.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.section,
      description: 'Vertical container for related blocks.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.columns,
      description: 'Two-column responsive layout.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.card,
      description: 'Framed group for compact content.',
    ),
    const _RecipeBlockDefinition(
      kind: _RecipeBlockKind.photoText,
      description: 'Photo beside explanatory text.',
    ),
  ];

  late final List<_RecipeTemplateDefinition> _templateDefinitions = [
    _RecipeTemplateDefinition(
      title: 'Classic method',
      description: 'Ingredients beside numbered steps.',
      icon: Icons.menu_book_rounded,
      createBlocks: (id) => [
        _RecipeEditorBlock(
          id: id('section'),
          kind: _RecipeBlockKind.section,
          title: 'Method',
          body: 'Keep the core flow compact and easy to scan.',
          width: _RecipeBlockWidth.wide,
          children: [
            _RecipeEditorBlock(
              id: id('ingredients'),
              kind: _RecipeBlockKind.ingredients,
              title: 'Ingredients',
              body: '1 onion\n2 garlic cloves\n400 g tomatoes',
              variant: _RecipeBlockVariant.cards,
            ),
            _RecipeEditorBlock(
              id: id('steps'),
              kind: _RecipeBlockKind.steps,
              title: 'Steps',
              body: 'Prep the ingredients.\nCook the base.\nFinish and serve.',
              variant: _RecipeBlockVariant.timeline,
            ),
          ],
        ),
      ],
    ),
    _RecipeTemplateDefinition(
      title: 'Story with photo',
      description: 'Intro, image, and a chef note.',
      icon: Icons.auto_stories_rounded,
      createBlocks: (id) => [
        _RecipeEditorBlock(
          id: id('section'),
          kind: _RecipeBlockKind.section,
          title: 'Before you start',
          body: 'Set context before the actual method.',
          children: [
            _RecipeEditorBlock(
              id: id('paragraph'),
              kind: _RecipeBlockKind.paragraph,
              title: 'Why this works',
              body:
                  'Short, practical context that helps the cook understand the recipe.',
            ),
            _RecipeEditorBlock(
              id: id('image'),
              kind: _RecipeBlockKind.image,
              title: 'Process photo',
              body: 'Show the key texture or color.',
              width: _RecipeBlockWidth.wide,
            ),
            _RecipeEditorBlock(
              id: id('note'),
              kind: _RecipeBlockKind.note,
              title: 'Chef note',
              body: 'A small adjustment that makes the result more reliable.',
            ),
          ],
        ),
      ],
    ),
    _RecipeTemplateDefinition(
      title: 'Prep checklist',
      description: 'Equipment, prep tasks, and timer.',
      icon: Icons.task_alt_rounded,
      createBlocks: (id) => [
        _RecipeEditorBlock(
          id: id('section'),
          kind: _RecipeBlockKind.section,
          title: 'Prep station',
          body: 'Get everything ready before heat hits the pan.',
          variant: _RecipeBlockVariant.cards,
          children: [
            _RecipeEditorBlock(
              id: id('equipment'),
              kind: _RecipeBlockKind.equipment,
              title: 'Equipment',
              body: 'Large skillet\nMixing bowl\nSharp knife',
            ),
            _RecipeEditorBlock(
              id: id('checklist'),
              kind: _RecipeBlockKind.checklist,
              title: 'Prep checklist',
              body: 'Wash produce\nMeasure spices\nPreheat oven',
            ),
            _RecipeEditorBlock(
              id: id('timer'),
              kind: _RecipeBlockKind.timer,
              title: 'Resting timer',
              body: '10 minutes',
            ),
          ],
        ),
      ],
    ),
  ];

  List<_RecipeEditorBlock> _initialBlocks() {
    final sectionId = _newBlockId('section');
    final ingredientsId = _newBlockId('ingredients');
    final stepsId = _newBlockId('steps');

    _selectedBlockId = sectionId;

    return [
      _RecipeEditorBlock(
        id: sectionId,
        kind: _RecipeBlockKind.section,
        title: 'Cooking flow',
        body: 'Build the main preparation story here.',
        width: _RecipeBlockWidth.wide,
        children: [
          _RecipeEditorBlock(
            id: ingredientsId,
            kind: _RecipeBlockKind.ingredients,
            title: 'Ingredients',
            body: '2 cups flour\n1 tsp salt\n1 cup warm water',
            variant: _RecipeBlockVariant.cards,
          ),
          _RecipeEditorBlock(
            id: stepsId,
            kind: _RecipeBlockKind.steps,
            title: 'Steps',
            body:
                'Mix the dry ingredients.\nFold in the wet ingredients.\nBake until golden.',
            variant: _RecipeBlockVariant.timeline,
          ),
        ],
      ),
    ];
  }

  String _newBlockId(String prefix) {
    _nextId += 1;
    return '$prefix-$_nextId';
  }

  _RecipeEditorBlock _createBlock(_RecipeBlockKind kind) {
    if (kind == _RecipeBlockKind.columns) {
      return _RecipeEditorBlock(
        id: _newBlockId(kind.name),
        kind: kind,
        title: kind.label,
        body: _defaultBodyForKind(kind),
        width: _RecipeBlockWidth.full,
        children: [
          _RecipeEditorBlock(
            id: _newBlockId('column'),
            kind: _RecipeBlockKind.column,
            title: 'Column',
            body: 'Drop blocks here.',
            width: _RecipeBlockWidth.full,
          ),
          _RecipeEditorBlock(
            id: _newBlockId('column'),
            kind: _RecipeBlockKind.column,
            title: 'Column',
            body: 'Drop blocks here.',
            width: _RecipeBlockWidth.full,
          ),
        ],
      );
    }

    if (kind == _RecipeBlockKind.photoText) {
      return _RecipeEditorBlock(
        id: _newBlockId(kind.name),
        kind: kind,
        title: kind.label,
        body: _defaultBodyForKind(kind),
        width: _RecipeBlockWidth.full,
        children: [
          _RecipeEditorBlock(
            id: _newBlockId('image'),
            kind: _RecipeBlockKind.image,
            title: 'Photo',
            body: 'Process image placeholder',
            width: _RecipeBlockWidth.full,
          ),
          _RecipeEditorBlock(
            id: _newBlockId('paragraph'),
            kind: _RecipeBlockKind.paragraph,
            title: 'Caption',
            body: 'Explain what the cook should look for here.',
            width: _RecipeBlockWidth.full,
          ),
        ],
      );
    }

    return _RecipeEditorBlock(
      id: _newBlockId(kind.name),
      kind: kind,
      title: kind.label,
      body: _defaultBodyForKind(kind),
      width: kind.group == _RecipeBlockGroup.layout
          ? _RecipeBlockWidth.wide
          : _RecipeBlockWidth.normal,
      variant: kind == _RecipeBlockKind.steps
          ? _RecipeBlockVariant.timeline
          : _RecipeBlockVariant.simple,
    );
  }

  String _defaultBodyForKind(_RecipeBlockKind kind) {
    return switch (kind) {
      _RecipeBlockKind.heading => 'New section',
      _RecipeBlockKind.paragraph =>
        'Write the cooking detail directly in the page preview.',
      _RecipeBlockKind.quote => 'A useful note from the cook.',
      _RecipeBlockKind.image => 'Image placeholder',
      _RecipeBlockKind.video => 'Video URL or embed placeholder',
      _RecipeBlockKind.note => 'Keep this tip short and practical.',
      _RecipeBlockKind.divider => '',
      _RecipeBlockKind.ingredients => 'Ingredient one\nIngredient two',
      _RecipeBlockKind.steps => 'First step\nSecond step',
      _RecipeBlockKind.equipment => 'Skillet\nKnife\nMixing bowl',
      _RecipeBlockKind.substitutions => 'Swap butter for olive oil.',
      _RecipeBlockKind.nutrition => 'Calories, protein, carbs, and fat.',
      _RecipeBlockKind.timer => '15 minutes',
      _RecipeBlockKind.servings => 'Serves 4',
      _RecipeBlockKind.checklist => 'Prep vegetables\nHeat pan',
      _RecipeBlockKind.section => 'Group related content here.',
      _RecipeBlockKind.columns => 'Responsive column group.',
      _RecipeBlockKind.column => 'Column content.',
      _RecipeBlockKind.card => 'Framed content group.',
      _RecipeBlockKind.photoText => 'Pair a photo with a short instruction.',
    };
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_syncOverlayVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncOverlayVisibility();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _RecipeBodyEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController == widget.scrollController) {
      return;
    }
    oldWidget.scrollController.removeListener(_syncOverlayVisibility);
    widget.scrollController.addListener(_syncOverlayVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncOverlayVisibility();
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_syncOverlayVisibility);
    _hoveredBlockId.dispose();
    super.dispose();
  }

  void _syncOverlayVisibility() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final headerHeight = AppSpacing.headerHeightForViewport(viewportWidth);
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final bottom = top + renderObject.size.height;
    final visible = bottom > headerHeight && top < viewportHeight - 80;

    if (visible && !_overlayController.isShowing) {
      _overlayController.show();
    } else if (!visible && _overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasPanel = _RecipeEditorCanvas(
      blocks: _blocks,
      selectedBlockId: _selectedBlockId,
      hoveredBlockId: _hoveredBlockId,
      onBlockSelected: _selectBlock,
      onSelectionCleared: _clearBlockSelection,
      onBlockTitleChanged: _updateBlockTitle,
      onBlockBodyChanged: _updateBlockBody,
      onBlockQuoteAuthorChanged: _updateBlockQuoteAuthor,
      onBlockHeightChanged: _updateBlockHeight,
      onBlockChanged: _replaceBlock,
      onAppendBlockRequested: _prepareAppendBlock,
      canDropBlock: _canDropBlock,
      onDropBlock: _dropBlock,
      onDeleteBlock: _deleteBlock,
    );

    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) => _RecipeEditorOverlay(
        activeTab: _activeTab,
        paletteExpanded: _paletteExpanded,
        inspectorExpanded: _inspectorExpanded,
        blockPaletteCue: _blockPaletteCue,
        templates: _templateDefinitions,
        blocks: _blockDefinitions,
        selectedBlock: _selectedBlock,
        onTabChanged: _setActiveTab,
        onPaletteExpandedChanged: (value) {
          setState(() {
            _paletteExpanded = value;
            if (value) {
              _inspectorExpanded = false;
            }
          });
        },
        onInspectorExpandedChanged: (value) {
          setState(() {
            _inspectorExpanded = value;
            if (value) {
              _paletteExpanded = false;
            }
          });
        },
        onTemplateSelected: _insertTemplate,
        onBlockSelected: _insertBlock,
        onWidthChanged: _updateSelectedBlockWidth,
        onAlignmentChanged: _updateSelectedBlockAlignment,
        onSpacingChanged: _updateSelectedBlockSpacing,
        onVariantChanged: _updateSelectedBlockVariant,
        onTextAlignmentChanged: _updateSelectedBlockTextAlignment,
        onTextSizeChanged: _updateSelectedBlockTextSize,
        onBlockChanged: _replaceBlock,
      ),
      child: canvasPanel,
    );
  }

  _RecipeEditorBlock? get _selectedBlock {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return null;
    }
    return _findBlock(_blocks, blockId);
  }

  _RecipeEditorBlock? _findBlock(
    List<_RecipeEditorBlock> blocks,
    String blockId,
  ) {
    for (final block in blocks) {
      if (block.id == blockId) {
        return block;
      }
      final child = _findBlock(block.children, blockId);
      if (child != null) {
        return child;
      }
    }
    return null;
  }

  void _setActiveTab(_RecipeEditorTab tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  void _selectBlock(String blockId) {
    setState(() {
      _selectedBlockId = blockId;
    });
  }

  void _clearBlockSelection() {
    if (_selectedBlockId == null) {
      return;
    }
    setState(() {
      _selectedBlockId = null;
    });
  }

  void _updateBlockTitle(String blockId, String title) {
    _updateBlock(blockId, (block) => block.copyWith(title: title));
  }

  void _updateBlockBody(String blockId, String body) {
    _updateBlock(blockId, (block) => block.copyWith(body: body));
  }

  void _updateBlockQuoteAuthor(String blockId, String author) {
    _updateBlock(blockId, (block) => block.copyWith(quoteAuthor: author));
  }

  void _updateBlockHeight(String blockId, double height) {
    _updateBlock(blockId, (block) => block.copyWith(editorHeight: height));
  }

  void _updateSelectedBlockWidth(_RecipeBlockWidth width) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(width: width));
  }

  void _updateSelectedBlockAlignment(_RecipeBlockAlignment alignment) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(alignment: alignment));
  }

  void _updateSelectedBlockSpacing(_RecipeBlockSpacing spacing) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(spacing: spacing));
  }

  void _updateSelectedBlockVariant(_RecipeBlockVariant variant) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(variant: variant));
  }

  void _updateSelectedBlockTextAlignment(_RecipeTextAlignment alignment) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(textAlignment: alignment));
  }

  void _updateSelectedBlockTextSize(_RecipeTextSize size) {
    final blockId = _selectedBlockId;
    if (blockId == null) {
      return;
    }
    _updateBlock(blockId, (block) => block.copyWith(textSize: size));
  }

  void _updateBlock(
    String blockId,
    _RecipeEditorBlock Function(_RecipeEditorBlock block) update,
  ) {
    setState(() {
      _blocks = _mapBlocks(_blocks, blockId, update);
    });
  }

  void _replaceBlock(_RecipeEditorBlock block) {
    _updateBlock(block.id, (_) => block);
  }

  List<_RecipeEditorBlock> _mapBlocks(
    List<_RecipeEditorBlock> blocks,
    String blockId,
    _RecipeEditorBlock Function(_RecipeEditorBlock block) update,
  ) {
    return [
      for (final block in blocks)
        if (block.id == blockId)
          update(block)
        else
          block.copyWith(children: _mapBlocks(block.children, blockId, update)),
    ];
  }

  void _insertTemplate(_RecipeTemplateDefinition template) {
    final blocks = template.createBlocks(_newBlockId);
    _insertBlocksUsingSelection(blocks);
  }

  void _insertBlock(_RecipeBlockDefinition block) {
    final target = _appendNextBlock
        ? _RecipeBlockDropTarget(
            parentId: null,
            index: _blocks.length,
            depth: 0,
          )
        : _insertionTargetAfterSelection(block.kind);
    _insertPaletteBlock(block, target);
  }

  void _prepareAppendBlock() {
    setState(() {
      _activeTab = _RecipeEditorTab.blocks;
      _appendNextBlock = true;
      _blockPaletteCue += 1;
    });
  }

  _RecipeBlockDropTarget _insertionTargetAfterSelection(_RecipeBlockKind kind) {
    var selectedId = _selectedBlockId;
    while (selectedId != null) {
      final location = _findBlockLocation(_blocks, selectedId);
      if (location == null) {
        break;
      }

      final target = _RecipeBlockDropTarget(
        parentId: location.parentId,
        index: location.index + 1,
        depth: location.depth,
      );
      if (_canInsertPaletteBlock(kind, target)) {
        return target;
      }
      selectedId = location.parentId;
    }

    return _RecipeBlockDropTarget(
      parentId: null,
      index: _blocks.length,
      depth: 0,
    );
  }

  void _insertPaletteBlock(
    _RecipeBlockDefinition definition,
    _RecipeBlockDropTarget target,
  ) {
    if (!_canInsertPaletteBlock(definition.kind, target)) {
      return;
    }

    final block = _createBlock(definition.kind);
    setState(() {
      _blocks = _insertMovedBlock(
        _blocks,
        target.parentId,
        target.index,
        block,
      );
      _selectedBlockId = block.id;
      _appendNextBlock = false;
    });
  }

  bool _canInsertPaletteBlock(
    _RecipeBlockKind kind,
    _RecipeBlockDropTarget target,
  ) {
    if (target.parentId != null) {
      final parent = _findBlock(_blocks, target.parentId!);
      if (parent == null || !parent.canContainChildren) {
        return false;
      }
    }

    final insertedTreeHeight = switch (kind) {
      _RecipeBlockKind.columns || _RecipeBlockKind.photoText => 2,
      _ => 1,
    };
    return target.depth + insertedTreeHeight - 1 <= _maxDepth;
  }

  bool _canMoveBlock(_RecipeBlockDragData data, _RecipeBlockDropTarget target) {
    final source = _findBlockLocation(_blocks, data.blockId);
    if (source == null) {
      return false;
    }

    if (source.parentId == target.parentId &&
        (target.index == source.index || target.index == source.index + 1)) {
      return false;
    }

    if (target.parentId == source.block.id ||
        _blockContains(source.block, target.parentId)) {
      return false;
    }

    if (target.parentId != null) {
      final parent = _findBlock(_blocks, target.parentId!);
      if (parent == null || !parent.canContainChildren) {
        return false;
      }
    }

    final movedTreeHeight = _blockTreeHeight(source.block);
    return target.depth + movedTreeHeight - 1 <= _maxDepth;
  }

  bool _canDropBlock(
    _RecipeEditorDragData data,
    _RecipeBlockDropTarget target,
  ) {
    return switch (data) {
      _RecipeBlockDragData() => _canMoveBlock(data, target),
      _RecipePaletteBlockDragData() => _canInsertPaletteBlock(
        data.block.kind,
        target,
      ),
      _ => false,
    };
  }

  void _dropBlock(_RecipeEditorDragData data, _RecipeBlockDropTarget target) {
    switch (data) {
      case _RecipeBlockDragData():
        _moveBlock(data, target);
        return;
      case _RecipePaletteBlockDragData():
        _insertPaletteBlock(data.block, target);
        return;
      default:
        return;
    }
  }

  void _moveBlock(_RecipeBlockDragData data, _RecipeBlockDropTarget target) {
    if (!_canMoveBlock(data, target)) {
      return;
    }

    setState(() {
      final source = _findBlockLocation(_blocks, data.blockId)!;
      final extraction = _extractBlock(_blocks, data.blockId);
      final movedBlock = extraction.block;
      if (movedBlock == null) {
        return;
      }

      var targetIndex = target.index;
      if (source.parentId == target.parentId && source.index < targetIndex) {
        targetIndex -= 1;
      }

      _blocks = _insertMovedBlock(
        extraction.blocks,
        target.parentId,
        targetIndex,
        movedBlock,
      );
      _selectedBlockId = movedBlock.id;
    });
  }

  _RecipeBlockLocation? _findBlockLocation(
    List<_RecipeEditorBlock> blocks,
    String blockId, {
    String? parentId,
    int depth = 0,
  }) {
    for (var index = 0; index < blocks.length; index++) {
      final block = blocks[index];
      if (block.id == blockId) {
        return _RecipeBlockLocation(
          block: block,
          parentId: parentId,
          index: index,
          depth: depth,
        );
      }

      final childLocation = _findBlockLocation(
        block.children,
        blockId,
        parentId: block.id,
        depth: depth + 1,
      );
      if (childLocation != null) {
        return childLocation;
      }
    }
    return null;
  }

  bool _blockContains(_RecipeEditorBlock block, String? blockId) {
    if (blockId == null) {
      return false;
    }
    for (final child in block.children) {
      if (child.id == blockId || _blockContains(child, blockId)) {
        return true;
      }
    }
    return false;
  }

  _RecipeBlockExtraction _extractBlock(
    List<_RecipeEditorBlock> blocks,
    String blockId,
  ) {
    for (var index = 0; index < blocks.length; index++) {
      final block = blocks[index];
      if (block.id == blockId) {
        return _RecipeBlockExtraction(
          blocks: [...blocks]..removeAt(index),
          block: block,
        );
      }

      final childExtraction = _extractBlock(block.children, blockId);
      if (childExtraction.block != null) {
        final nextBlocks = [...blocks];
        nextBlocks[index] = block.copyWith(children: childExtraction.blocks);
        return _RecipeBlockExtraction(
          blocks: nextBlocks,
          block: childExtraction.block,
        );
      }
    }
    return _RecipeBlockExtraction(blocks: blocks);
  }

  List<_RecipeEditorBlock> _insertMovedBlock(
    List<_RecipeEditorBlock> blocks,
    String? parentId,
    int index,
    _RecipeEditorBlock movedBlock,
  ) {
    if (parentId == null) {
      final targetIndex = index.clamp(0, blocks.length).toInt();
      return [...blocks]..insert(targetIndex, movedBlock);
    }

    return [
      for (final block in blocks)
        if (block.id == parentId)
          block.copyWith(
            children: [...block.children]
              ..insert(
                index.clamp(0, block.children.length).toInt(),
                movedBlock,
              ),
          )
        else
          block.copyWith(
            children: _insertMovedBlock(
              block.children,
              parentId,
              index,
              movedBlock,
            ),
          ),
    ];
  }

  void _deleteBlock(String blockId) {
    setState(() {
      _blocks = _removeBlockFromList(_blocks, blockId);
      if (_selectedBlockId == blockId) {
        _selectedBlockId = _blocks.isEmpty ? null : _blocks.first.id;
      }
    });
  }

  List<_RecipeEditorBlock> _removeBlockFromList(
    List<_RecipeEditorBlock> blocks,
    String blockId,
  ) {
    return [
      for (final block in blocks)
        if (block.id != blockId)
          block.copyWith(
            children: _removeBlockFromList(block.children, blockId),
          ),
    ];
  }

  void _insertRootBlocks(List<_RecipeEditorBlock> blocks) {
    if (blocks.isEmpty) {
      return;
    }

    setState(() {
      _blocks = [..._blocks, ...blocks];
      _selectedBlockId = blocks.last.id;
    });
  }

  void _insertBlocksUsingSelection(List<_RecipeEditorBlock> blocks) {
    if (blocks.isEmpty) {
      return;
    }

    final selected = _selectedBlock;
    final selectedId = selected?.id;
    if (selected == null ||
        selectedId == null ||
        !_canInsertBlocksInto(selectedId, selected, blocks)) {
      _insertRootBlocks(blocks);
      return;
    }

    setState(() {
      _blocks = _insertChildrenInto(_blocks, selectedId, blocks);
      _selectedBlockId = blocks.last.id;
    });
  }

  bool _canInsertBlocksInto(
    String parentId,
    _RecipeEditorBlock parent,
    List<_RecipeEditorBlock> blocks,
  ) {
    if (!parent.canContainChildren) {
      return false;
    }

    final parentDepth = _depthOfBlock(_blocks, parentId);
    if (parentDepth == null) {
      return false;
    }

    final insertedHeight = blocks.fold<int>(1, (height, block) {
      final blockHeight = _blockTreeHeight(block);
      return blockHeight > height ? blockHeight : height;
    });

    return parentDepth + insertedHeight <= _maxDepth;
  }

  int? _depthOfBlock(
    List<_RecipeEditorBlock> blocks,
    String blockId, [
    int depth = 0,
  ]) {
    for (final block in blocks) {
      if (block.id == blockId) {
        return depth;
      }
      final childDepth = _depthOfBlock(block.children, blockId, depth + 1);
      if (childDepth != null) {
        return childDepth;
      }
    }
    return null;
  }

  int _blockTreeHeight(_RecipeEditorBlock block) {
    if (block.children.isEmpty) {
      return 1;
    }

    return 1 +
        block.children.fold<int>(0, (height, child) {
          final childHeight = _blockTreeHeight(child);
          return childHeight > height ? childHeight : height;
        });
  }

  List<_RecipeEditorBlock> _insertChildrenInto(
    List<_RecipeEditorBlock> blocks,
    String parentId,
    List<_RecipeEditorBlock> children,
  ) {
    return [
      for (final block in blocks)
        if (block.id == parentId)
          block.copyWith(children: [...block.children, ...children])
        else
          block.copyWith(
            children: _insertChildrenInto(block.children, parentId, children),
          ),
    ];
  }
}
