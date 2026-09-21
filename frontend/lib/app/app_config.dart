enum AppDataMode { api, mock }

class AppConfig {
  const AppConfig({this.dataMode = AppDataMode.api});

  factory AppConfig.fromEnvironment() {
    const value = String.fromEnvironment(
      'CHEFIFY_DATA_MODE',
      defaultValue: 'api',
    );
    return const AppConfig(
      dataMode: value == 'mock' ? AppDataMode.mock : AppDataMode.api,
    );
  }

  final AppDataMode dataMode;

  bool get usesMockData => dataMode == AppDataMode.mock;
}
