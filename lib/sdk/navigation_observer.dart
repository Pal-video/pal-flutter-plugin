import 'package:flutter/material.dart';

import '../api/pal.dart';

class PalNavigatorObserver extends RouteObserver<PageRoute<dynamic>> {
  Pal _pal;

  @visibleForTesting
  PalNavigatorObserver({required Pal pal}) : _pal = pal;

  factory PalNavigatorObserver.create() => PalNavigatorObserver(
        pal: Pal.instance,
      );

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute == null) {
      return;
    }
    _logRoute(newRoute);
  }

  _logRoute(Route<dynamic> route) {
    debugPrint("PalNavigatorObserver: ${route.settings.name}");
    if (route.settings.name != null && navigator?.context != null) {
      _pal.logCurrentScreen(
        navigator!.context,
        route.settings.name!,
      );
    }
  }
}
