import 'package:flutter/widgets.dart';
import 'package:frontend/shared/models/home_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _recipeIdsKey = 'chefify.bookmarks.recipeIds';
const _categoryIdsKey = 'chefify.bookmarks.categoryIds';

String _storageKey(String base, String? ownerId) {
  final owner = ownerId?.trim();
  return owner == null || owner.isEmpty
      ? base
      : '$base.${Uri.encodeComponent(owner)}';
}

class BookmarkSnapshot {
  const BookmarkSnapshot({
    this.recipeIds = const <String>{},
    this.categoryIds = const <String>{},
  });

  final Set<String> recipeIds;
  final Set<String> categoryIds;

  BookmarkSnapshot copy() {
    return BookmarkSnapshot(
      recipeIds: Set<String>.of(recipeIds),
      categoryIds: Set<String>.of(categoryIds),
    );
  }
}

abstract class BookmarkStorage {
  Future<BookmarkSnapshot> load({String? ownerId});

  Future<void> save(BookmarkSnapshot snapshot, {String? ownerId});
}

class SharedPreferencesBookmarkStorage implements BookmarkStorage {
  SharedPreferencesBookmarkStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<BookmarkSnapshot> load({String? ownerId}) async {
    final recipeIds = await _preferences.getStringList(
      _storageKey(_recipeIdsKey, ownerId),
    );
    final categoryIds = await _preferences.getStringList(
      _storageKey(_categoryIdsKey, ownerId),
    );

    return BookmarkSnapshot(
      recipeIds: recipeIds?.toSet() ?? const <String>{},
      categoryIds: categoryIds?.toSet() ?? const <String>{},
    );
  }

  @override
  Future<void> save(BookmarkSnapshot snapshot, {String? ownerId}) async {
    await Future.wait(<Future<void>>[
      _preferences.setStringList(
        _storageKey(_recipeIdsKey, ownerId),
        _sorted(snapshot.recipeIds),
      ),
      _preferences.setStringList(
        _storageKey(_categoryIdsKey, ownerId),
        _sorted(snapshot.categoryIds),
      ),
    ]);
  }
}

class MemoryBookmarkStorage implements BookmarkStorage {
  MemoryBookmarkStorage([
    BookmarkSnapshot initial = const BookmarkSnapshot(),
    String? ownerId,
  ]) : _snapshots = <String, BookmarkSnapshot>{ownerId ?? '': initial.copy()};

  final Map<String, BookmarkSnapshot> _snapshots;

  BookmarkSnapshot get snapshot =>
      (_snapshots[''] ?? const BookmarkSnapshot()).copy();

  @override
  Future<BookmarkSnapshot> load({String? ownerId}) async {
    return (_snapshots[ownerId ?? ''] ?? const BookmarkSnapshot()).copy();
  }

  @override
  Future<void> save(BookmarkSnapshot snapshot, {String? ownerId}) async {
    _snapshots[ownerId ?? ''] = snapshot.copy();
  }
}

class BookmarkStore extends ChangeNotifier {
  BookmarkStore({BookmarkStorage? storage})
    : _storage = storage ?? SharedPreferencesBookmarkStorage();

  BookmarkStore.memory([
    BookmarkSnapshot initial = const BookmarkSnapshot(),
    String? ownerId,
  ]) : _storage = MemoryBookmarkStorage(initial, ownerId),
       _ownerId = ownerId {
    _applySnapshot(initial);
    _isLoaded = true;
  }

  final BookmarkStorage _storage;
  final Set<String> _recipeIds = <String>{};
  final Set<String> _categoryIds = <String>{};

  bool _isLoaded = false;
  bool _isDirty = false;
  int _version = 0;
  Future<void>? _loadFuture;
  String? _ownerId;

  bool get isLoaded => _isLoaded;
  int get version => _version;

  Future<void> load() {
    if (_isLoaded) {
      return Future<void>.value();
    }
    return _loadFuture ??= _load();
  }

  Future<void> useOwner(String? ownerId) async {
    final normalized = ownerId?.trim();
    final nextOwner = normalized == null || normalized.isEmpty
        ? null
        : normalized;
    if (_ownerId == nextOwner) {
      return load();
    }

    _ownerId = nextOwner;
    _isLoaded = false;
    _isDirty = false;
    _loadFuture = null;
    _recipeIds.clear();
    _categoryIds.clear();
    _version++;
    notifyListeners();
    await load();
  }

  bool isRecipeSaved(RecipeModel recipe) {
    return _isSaved(ids: _recipeIds, id: recipe.id, fallback: recipe.isSaved);
  }

  bool isCategorySaved(CategoryModel category) {
    return _isSaved(
      ids: _categoryIds,
      id: category.id,
      fallback: category.isSaved,
    );
  }

  Future<void> toggleRecipe(RecipeModel recipe) {
    return setRecipeSaved(recipe, !isRecipeSaved(recipe));
  }

  Future<void> toggleCategory(CategoryModel category) {
    return setCategorySaved(category, !isCategorySaved(category));
  }

  Future<void> setRecipeSaved(RecipeModel recipe, bool isSaved) async {
    if (isRecipeSaved(recipe) == isSaved) {
      return;
    }
    _setSaved(_recipeIds, recipe.id, isSaved);
    await _persist();
  }

  Future<void> setCategorySaved(CategoryModel category, bool isSaved) async {
    if (isCategorySaved(category) == isSaved) {
      return;
    }
    _setSaved(_categoryIds, category.id, isSaved);
    await _persist();
  }

  Future<void> _load() async {
    final ownerAtStart = _ownerId;
    final snapshot = await _storage.load(ownerId: ownerAtStart);
    if (ownerAtStart != _ownerId) {
      return;
    }
    if (!_isDirty) {
      _applySnapshot(snapshot);
    }
    _isLoaded = true;
    _version++;
    notifyListeners();
  }

  bool _isSaved({
    required Set<String> ids,
    required String id,
    required bool fallback,
  }) {
    if (_isLoaded || _isDirty) {
      return ids.contains(id);
    }
    return fallback;
  }

  void _setSaved(Set<String> ids, String id, bool isSaved) {
    if (isSaved) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    _isDirty = true;
    _version++;
    notifyListeners();
  }

  Future<void> _persist() {
    return _storage.save(
      BookmarkSnapshot(
        recipeIds: Set<String>.of(_recipeIds),
        categoryIds: Set<String>.of(_categoryIds),
      ),
      ownerId: _ownerId,
    );
  }

  void _applySnapshot(BookmarkSnapshot snapshot) {
    _recipeIds
      ..clear()
      ..addAll(snapshot.recipeIds);
    _categoryIds
      ..clear()
      ..addAll(snapshot.categoryIds);
  }
}

class BookmarkScope extends InheritedNotifier<BookmarkStore> {
  const BookmarkScope({
    super.key,
    required BookmarkStore store,
    required super.child,
  }) : super(notifier: store);

  static BookmarkStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BookmarkScope>();
    assert(scope != null, 'BookmarkScope is missing in widget tree.');
    return scope!.notifier!;
  }
}

List<String> _sorted(Set<String> ids) {
  return ids.toList()..sort();
}
