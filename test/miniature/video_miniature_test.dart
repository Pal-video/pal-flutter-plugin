import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal/pal.dart';

void main() {
  Future beforeEach(WidgetTester tester) async {
    var app = MaterialApp(
      home: Scaffold(
        body: VideoMiniature(
          radius: 100,
          videoAsset: 'assets/me.mp4',
          onTap: () {},
        ),
      ),
    );
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('should play a video in loop mode', (WidgetTester tester) async {
    await beforeEach(tester);
  });
}
