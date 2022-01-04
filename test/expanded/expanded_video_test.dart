import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal/expanded/video_expanded.dart';

void main() {
  testWidgets('should play a video ', (WidgetTester tester) async {
    var app = const MaterialApp(
      home: Scaffold(
        body: VideoExpanded(
          videoAsset: 'assets/me.mp4',
          companyTitle: "CEO",
          userName: 'Marty Mcfly',
        ),
      ),
    );
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 500));
  });

  group('onSkip', () {
    Future beforeEach(WidgetTester tester) async {
      var app = MaterialApp(
        home: Scaffold(
          body: VideoExpanded(
            videoAsset: 'assets/me.mp4',
            onSkip: () => {},
            onSkipText: "SKIP VIDEO",
            companyTitle: "CEO",
            userName: 'Marty Mcfly',
          ),
        ),
      );
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('onSkip is visible, skip text is visible',
        (WidgetTester tester) async {
      await beforeEach(tester);
      expect(find.text("SKIP VIDEO"), findsOneWidget);
    });
  });
  group('onSkip is null', () {
    Future beforeEach(WidgetTester tester) async {
      var app = const MaterialApp(
        home: Scaffold(
          body: VideoExpanded(
            videoAsset: 'assets/me.mp4',
            companyTitle: "CEO",
            userName: 'Marty Mcfly',
          ),
        ),
      );
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('onSkip is not visible', (WidgetTester tester) async {
      await beforeEach(tester);
      expect(find.text("SKIP"), findsNothing);
    });
  });
}
