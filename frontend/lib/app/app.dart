import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/app/theme.dart';
import 'package:frontend/core/seo/seo_navigator_observer.dart';
import 'package:frontend/features/auth/data/api_auth_repository.dart';
import 'package:frontend/features/auth/domain/auth_repository.dart';
import 'package:frontend/features/auth/presentation/auth_controller.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';

class ChefifyApp extends StatefulWidget {
  const ChefifyApp({
    super.key,
    this.bookmarkStore,
    this.recipeRepository = const ApiRecipeRepository(),
    this.authRepository,
    this.settingsStorage,
  });

  final BookmarkStore? bookmarkStore;
  final RecipeRepository recipeRepository;
  final AuthRepository? authRepository;
  final AppSettingsStorage? settingsStorage;

  @override
  State<ChefifyApp> createState() => _ChefifyAppState();
}

class _ChefifyAppState extends State<ChefifyApp> {
  late final AppSettingsController _settingsController;
  late final BookmarkStore _bookmarkStore;
  late final bool _ownsBookmarkStore;
  late final SeoNavigatorObserver _seoNavigatorObserver;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _settingsController = AppSettingsController(
      storage: widget.settingsStorage,
    );
    _settingsController.load();
    _authController = AuthController(
      repository: widget.authRepository ?? ApiAuthRepository(),
    );
    _authController.restore();
    _seoNavigatorObserver = SeoNavigatorObserver();
    _ownsBookmarkStore = widget.bookmarkStore == null;
    _bookmarkStore = widget.bookmarkStore ?? BookmarkStore();
    _bookmarkStore.load();
  }

  @override
  void dispose() {
    _settingsController.dispose();
    _authController.dispose();
    if (_ownsBookmarkStore) {
      _bookmarkStore.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: _authController,
      child: BookmarkScope(
        store: _bookmarkStore,
        child: AppSettingsScope(
          controller: _settingsController,
          child: AnimatedBuilder(
            animation: _settingsController,
            builder: (context, _) {
              return MaterialApp(
                title: 'Chefify',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: _settingsController.themeMode,
                locale: _settingsController.locale,
                supportedLocales: AppLanguage.values.map(
                  (language) => language.locale,
                ),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                navigatorObservers: [_seoNavigatorObserver],
                onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
                  settings,
                  recipeRepository: widget.recipeRepository,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
