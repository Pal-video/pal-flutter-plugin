import 'package:flutter/material.dart';

Offset getWidgetPosition(GlobalKey key) {
  RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
  return box.localToGlobal(Offset.zero);
}

double getWidgetHeight(GlobalKey key) {
  RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
  return box.size.height;
}
