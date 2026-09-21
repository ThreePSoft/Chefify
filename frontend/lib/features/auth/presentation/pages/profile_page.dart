import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/localization/app_strings.dart';
import 'package:frontend/core/routing/slug.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:frontend/features/auth/presentation/auth_controller.dart';
import 'package:frontend/features/home/presentation/widgets/app_header.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/features/recipes/presentation/controllers/recipe_collection_controller.dart';
import 'package:frontend/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:frontend/features/recipes/presentation/widgets/recipe_collection_states.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:frontend/shared/models/home_models.dart';

part '../profile/profile_create_button.dart';
part '../profile/profile_header.dart';
part '../profile/profile_recipe_grid.dart';
part '../profile/profile_settings.dart';
part '../profile/profile_tabs.dart';

enum _ProfileTab { recipes, favorites, settings }

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.recipeRepository = const ApiRecipeRepository(),
  });

  final RecipeRepository recipeRepository;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final RecipeCollectionController _recipesController;
  List<RecipeModel> _allRecipes = const [];
  _ProfileTab _selectedTab = _ProfileTab.recipes;

  @override
  void initState() {
    super.initState();
    _recipesController = RecipeCollectionController(
      repository: widget.recipeRepository,
    )..addListener(_handleRecipesChanged);
    unawaited(_recipesController.load());
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeRepository != widget.recipeRepository) {
      _recipesController.replaceRepository(widget.recipeRepository);
      unawaited(_recipesController.load());
    }
  }

  @override
  void dispose() {
    _recipesController
      ..removeListener(_handleRecipesChanged)
      ..dispose();
    super.dispose();
  }

  void _handleRecipesChanged() {
    if (!mounted) return;
    setState(() {
      _allRecipes = _recipesController.recipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final strings = AppStrings.of(context);
    final user = auth.user;
    final ownRecipes = user == null
        ? const <RecipeModel>[]
        : _allRecipes
              .where(
                (recipe) => createSlug(recipe.author) == createSlug(user.name),
              )
              .toList(growable: false);
    final bookmarks = BookmarkScope.of(context);
    final favoriteRecipes = _allRecipes
        .where(bookmarks.isRecipeSaved)
        .toList(growable: false);

    return Scaffold(
      floatingActionButton: user != null && _selectedTab == _ProfileTab.recipes
          ? _ProfileCreateButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRouter.recipeCreate),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.horizontalPadding(context),
                  AppSpacing.lg,
                  AppSpacing.horizontalPadding(context),
                  AppSpacing.sectionGap,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.contentMaxWidth,
                    ),
                    child: user == null
                        ? _GuestProfile(strings: strings)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ProfileHeader(
                                user: user,
                                recipeCount: ownRecipes.length,
                                favoriteCount: favoriteRecipes.length,
                                onEdit: () =>
                                    _showEditProfileDialog(context, auth),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _ProfileTabs(
                                selected: _selectedTab,
                                onSelected: (tab) {
                                  setState(() {
                                    _selectedTab = tab;
                                  });
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _buildSelectedContent(
                                context,
                                auth: auth,
                                ownRecipes: ownRecipes,
                                favoriteRecipes: favoriteRecipes,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedContent(
    BuildContext context, {
    required AuthController auth,
    required List<RecipeModel> ownRecipes,
    required List<RecipeModel> favoriteRecipes,
  }) {
    if (_selectedTab == _ProfileTab.settings) {
      return _ProfileSettings(
        user: auth.user!,
        onEditProfile: () => _showEditProfileDialog(context, auth),
        onSignOut: () => _signOut(context, auth),
      );
    }

    final recipes = _selectedTab == _ProfileTab.recipes
        ? ownRecipes
        : favoriteRecipes;
    if (_recipesController.isLoading && _allRecipes.isEmpty) {
      return const RecipeCollectionLoading();
    }
    if (_recipesController.hasError && _allRecipes.isEmpty) {
      return RecipeCollectionError(
        error: _recipesController.error,
        onRetry: () => unawaited(_recipesController.load()),
      );
    }
    return _ProfileRecipeGrid(
      recipes: recipes,
      emptyMessage: _selectedTab == _ProfileTab.recipes
          ? AppStrings.of(context).noOwnRecipes
          : AppStrings.of(context).noFavoriteRecipes,
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    AuthController auth,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _EditProfileDialog(user: auth.user!),
    );
    if (name == null || !context.mounted) return;
    final updated = await auth.updateProfile(name: name);
    if (!updated && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).authServerError)),
      );
    }
  }

  Future<void> _signOut(BuildContext context, AuthController auth) async {
    await auth.signOut();
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
    }
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.lock_person_rounded, size: 56),
          const SizedBox(height: AppSpacing.md),
          Text(
            strings.profileGuestTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              AppButton(
                label: strings.logIn,
                variant: AppButtonVariant.outlined,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.login),
              ),
              AppButton(
                label: strings.createAccount,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.register),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
