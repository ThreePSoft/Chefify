import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app_settings.dart';

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
}
