import 'package:flutter/material.dart';

class OverlayHelper {
  GlobalKey<NavigatorState> navigatorKey;
  OverlayEntry? overlayEntry;

  OverlayHelper(this.navigatorKey);

  showHelper(WidgetBuilder widgetBuilder) {
    popHelper();
    overlayEntry = OverlayEntry(
      opaque: false,
      builder: widgetBuilder,
    );
    final overlay = navigatorKey.currentState?.overlay;
    assert(overlay != null, "No overlay for context found");
    if (overlay != null) {
      overlay.insert(overlayEntry!);
    }
  }

  bool popHelper() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
      return true;
    }
    return false;
  }
}
