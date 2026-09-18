import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app_settings.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/features/recipes/data/recipe_repository.dart';
import 'package:frontend/shared/bookmarks/bookmark_store.dart';

void main() {
  test('loads and persists theme and language preferences', () async {
    final storage = MemoryAppSettingsStorage(
      const AppSettingsSnapshot(
        themeMode: ThemeMode.light,
        language: AppLanguage.uk,
      ),
    );
    final controller = AppSettingsController(storage: storage);

    await controller.load();

    expect(controller.themeMode, ThemeMode.light);
    expect(controller.language, AppLanguage.uk);
    expect(controller.locale, const Locale('uk'));

    controller.setThemeMode(ThemeMode.dark);
    controller.setLanguage(AppLanguage.es);
    await Future<void>.delayed(Duration.zero);

    expect(storage.snapshot.themeMode, ThemeMode.dark);
    expect(storage.snapshot.language, AppLanguage.es);
  });

  testWidgets('applies the saved locale to Material and catalog copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bookmarks = BookmarkStore.memory();
    addTearDown(bookmarks.dispose);

    await tester.pumpWidget(
      ChefifyApp(
        bookmarkStore: bookmarks,
        recipeRepository: const MockRecipeRepository(),
        settingsStorage: MemoryAppSettingsStorage(
          const AppSettingsSnapshot(language: AppLanguage.uk),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('uk'),
    );
    expect(find.text('Рецепти'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, 'Рецепти'));
    await tester.pumpAndSettle();
    expect(find.text('Знайдіть наступний рецепт'), findsOneWidget);
  });
}
