import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());
  runApp(ChefifyApp(config: AppConfig.fromEnvironment()));
}
