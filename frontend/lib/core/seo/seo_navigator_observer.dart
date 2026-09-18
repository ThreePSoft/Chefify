import 'package:flutter/widgets.dart';
import 'package:frontend/core/seo/app_seo.dart';

class SeoNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _resetSeo();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _resetSeo();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _resetSeo();
  }

  void _resetSeo() {
    setDefaultSeo();
  }
}
