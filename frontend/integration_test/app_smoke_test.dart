import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders the main Chefify browser flow', (tester) async {
    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
      ),
    );
    await _pumpUntilFound(tester, find.text('Recipes everyone is saving'));

    expect(find.text('Chefify'), findsWidgets);
    expect(find.text('Recipes everyone is saving'), findsOneWidget);
    expect(find.byKey(const ValueKey('hero-browse-recipes')), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 60; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Timed out waiting for the expected widget.');
}
