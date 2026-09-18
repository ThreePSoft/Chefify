typedef RecipeImageUrlRevoker = void Function(String imageUrl);

class RecipeImageUrlRegistry {
  RecipeImageUrlRegistry(this._revoke);

  final RecipeImageUrlRevoker _revoke;
  final Set<String> _activeUrls = <String>{};

  int get activeUrlCount => _activeUrls.length;

  void register(String imageUrl) {
    _activeUrls.add(imageUrl);
  }

  void release(String? imageUrl) {
    if (imageUrl == null || !_activeUrls.remove(imageUrl)) {
      return;
    }

    _revoke(imageUrl);
  }

  void releaseAll() {
    for (final imageUrl in _activeUrls.toList(growable: false)) {
      release(imageUrl);
    }
  }
}
