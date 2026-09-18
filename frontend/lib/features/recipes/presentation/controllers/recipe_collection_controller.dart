import 'package:flutter/foundation.dart';
import 'package:frontend/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:frontend/shared/models/home_models.dart';

enum RecipeCollectionStatus { initial, loading, success, failure }

final class RecipeCollectionController extends ChangeNotifier {
  RecipeCollectionController({required RecipeRepository repository})
    : _repository = repository;

  RecipeRepository _repository;
  RecipeCollectionStatus _status = RecipeCollectionStatus.initial;
  List<RecipeModel> _recipes = const [];
  Object? _error;
  int _requestVersion = 0;
  bool _isDisposed = false;

  RecipeCollectionStatus get status => _status;
  List<RecipeModel> get recipes => _recipes;
  Object? get error => _error;
  bool get isLoading => _status == RecipeCollectionStatus.loading;
  bool get hasError => _status == RecipeCollectionStatus.failure;

  void replaceRepository(RecipeRepository repository) {
    _repository = repository;
  }

  Future<void> load() async {
    final requestVersion = ++_requestVersion;
    _status = RecipeCollectionStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final recipes = await _repository.fetchRecipes();
      if (!_isCurrent(requestVersion)) {
        return;
      }

      _recipes = List.unmodifiable(recipes);
      _status = RecipeCollectionStatus.success;
    } on Object catch (error) {
      if (!_isCurrent(requestVersion)) {
        return;
      }

      _error = error;
      _status = RecipeCollectionStatus.failure;
    }

    notifyListeners();
  }

  bool _isCurrent(int requestVersion) {
    return !_isDisposed && requestVersion == _requestVersion;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestVersion++;
    super.dispose();
  }
}
