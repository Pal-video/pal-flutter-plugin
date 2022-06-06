import 'package:flutter/material.dart';

import '../api/pal.dart';

class PalNavigatorObserver extends RouteObserver<PageRoute<dynamic>> {
  static PalNavigatorObserver? _instance;

  Pal _pal;

  @visibleForTesting
  PalNavigatorObserver({required Pal pal}) : _pal = pal;

  factory PalNavigatorObserver.create() {
    return PalNavigatorObserver(pal: Pal.instance);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRoute(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute == null) {
      return;
    }
    _logRoute(newRoute);
  }

  _logRoute(Route<dynamic> route) {
    if (route.settings.name != null && route.navigator?.context != null) {
      _pal.logCurrentScreen(route.navigator!.context, route.settings.name!);
    }
  }
}
