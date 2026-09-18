import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'chefify.settings.themeMode';
const _languageKey = 'chefify.settings.language';

enum AppLanguage { en, uk, es }

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
    AppLanguage.en => 'en',
    AppLanguage.uk => 'uk',
    AppLanguage.es => 'es',
  };

  String get label => switch (this) {
    AppLanguage.en => 'English',
    AppLanguage.uk => 'Українська',
    AppLanguage.es => 'Español',
  };

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.en,
    );
  }
}

@immutable
class AppSettingsSnapshot {
  const AppSettingsSnapshot({
    this.themeMode = ThemeMode.dark,
    this.language = AppLanguage.en,
  });

  final ThemeMode themeMode;
  final AppLanguage language;
}

abstract class AppSettingsStorage {
  Future<AppSettingsSnapshot> load();

  Future<void> save(AppSettingsSnapshot snapshot);
}

class SharedPreferencesAppSettingsStorage implements AppSettingsStorage {
  SharedPreferencesAppSettingsStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppSettingsSnapshot> load() async {
    final values = await Future.wait<String?>([
      _preferences.getString(_themeModeKey),
      _preferences.getString(_languageKey),
    ]);
    return AppSettingsSnapshot(
      themeMode: values.first == ThemeMode.light.name
          ? ThemeMode.light
          : ThemeMode.dark,
      language: AppLanguageX.fromCode(values.last),
    );
  }

  @override
  Future<void> save(AppSettingsSnapshot snapshot) async {
    await Future.wait<void>([
      _preferences.setString(_themeModeKey, snapshot.themeMode.name),
      _preferences.setString(_languageKey, snapshot.language.code),
    ]);
  }
}

class MemoryAppSettingsStorage implements AppSettingsStorage {
  MemoryAppSettingsStorage([this.snapshot = const AppSettingsSnapshot()]);

  AppSettingsSnapshot snapshot;

  @override
  Future<AppSettingsSnapshot> load() async => snapshot;

  @override
  Future<void> save(AppSettingsSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

class AppSettingsController extends ChangeNotifier {
  AppSettingsController({
    ThemeMode initialThemeMode = ThemeMode.dark,
    AppLanguage initialLanguage = AppLanguage.en,
    AppSettingsStorage? storage,
  }) : _themeMode = initialThemeMode,
       _language = initialLanguage,
       _storage = storage ?? SharedPreferencesAppSettingsStorage();

  final AppSettingsStorage _storage;
  ThemeMode _themeMode;
  AppLanguage _language;
  Future<void>? _loadFuture;

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  Locale get locale => _language.locale;

  Future<void> load() => _loadFuture ??= _load();

  Future<void> _load() async {
    final snapshot = await _storage.load();
    _themeMode = snapshot.themeMode;
    _language = snapshot.language;
    notifyListeners();
  }

  void setThemeMode(ThemeMode themeMode) {
    if (themeMode != ThemeMode.light && themeMode != ThemeMode.dark) {
      return;
    }
    if (_themeMode == themeMode) {
      return;
    }
    _themeMode = themeMode;
    notifyListeners();
    unawaited(_persist());
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) {
      return;
    }
    _language = language;
    notifyListeners();
    unawaited(_persist());
  }

  Future<void> _persist() {
    return _storage.save(
      AppSettingsSnapshot(themeMode: _themeMode, language: _language),
    );
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope is missing in widget tree.');
    return scope!.notifier!;
  }
}
