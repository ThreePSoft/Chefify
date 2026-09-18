import 'package:flutter/widgets.dart';
import 'package:frontend/core/seo/app_seo.dart';

class SeoNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _resetForRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _resetForRoute(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _resetForRoute(newRoute);
  }

  void _resetForRoute(Route<dynamic>? route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setDefaultSeo();
    });
  }
}
