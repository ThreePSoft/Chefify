import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/widgets/app_card.dart';
import 'package:frontend/features/recipes/domain/repositories/recipe_repository.dart';

class RecipeCollectionLoading extends StatelessWidget {
  const RecipeCollectionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class RecipeCollectionError extends StatelessWidget {
  const RecipeCollectionError({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AppCard(
      key: const ValueKey('recipe-collection-error'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 40, color: palette.categoryTags),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Could not load recipes',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _messageFor(error),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.secondaryText),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            key: const ValueKey('retry-recipe-collection'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  String _messageFor(Object? error) {
    if (error is! RecipeRepositoryFailure) {
      return 'An unexpected error occurred. Please try again.';
    }

    return switch (error.kind) {
      RecipeRepositoryFailureKind.network =>
        'Check your connection and try again.',
      RecipeRepositoryFailureKind.timeout =>
        'The server took too long to respond. Please retry.',
      RecipeRepositoryFailureKind.server =>
        'The recipes service is temporarily unavailable.',
      RecipeRepositoryFailureKind.invalidResponse =>
        'The server returned data Chefify could not read.',
    };
  }
}
