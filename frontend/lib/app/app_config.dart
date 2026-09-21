enum AppDataMode { api, test }

class AppConfig {
  const AppConfig({this.dataMode = AppDataMode.api});

  factory AppConfig.fromEnvironment() {
    const value = String.fromEnvironment(
      'CHEFIFY_DATA_MODE',
      defaultValue: 'api',
    );
    return const AppConfig(
      dataMode: value == 'test' || value == 'mock'
          ? AppDataMode.test
          : AppDataMode.api,
    );
  }

  final AppDataMode dataMode;

  bool get includesMockData => dataMode == AppDataMode.test;
}
