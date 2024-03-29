import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_video/expanded/video_expanded.dart';
import 'package:pal_video/pal.dart';
import 'package:pal_video/surveys/single_choice/single_choice.dart';

void main() {
  group('miniature > video > single choice', () {
    final navigatorKey = GlobalKey<NavigatorState>();

    final PalSdk palSdk = PalSdk.fromKey(navigatorKey: navigatorKey);

    Future beforeEach(WidgetTester tester) async {
      var app = MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Container(),
        ),
      );
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 500));
      // show a single choice video
      await palSdk.showSingleChoiceSurvey(
        videoAsset: 'assets/me.mp4',
        userName: 'Gautier',
        companyTitle: 'Apparence.io CTO',
        question: 'my question lorem ipsum lorem',
        choices: const [
          Choice(code: 'a', text: 'lorem A'),
          Choice(code: 'b', text: 'lorem B'),
          Choice(code: 'c', text: 'lorem C'),
          Choice(code: 'd', text: 'lorem D'),
        ],
        onTapChoice: (choice) {},
        onVideoEndAction: () {},
      );
    }

    testWidgets('miniature is visible, click => show expanded video',
        (WidgetTester tester) async {
      await beforeEach(tester);

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(VideoMiniature), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      final miniature = _miniatureWidget;
      miniature.onTap();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(VideoExpanded), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('''
        click miniature then wait end of video 
        => a single form is shown
        ''', (
      WidgetTester tester,
    ) async {
      await beforeEach(tester);

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(VideoMiniature), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      final miniature = _miniatureWidget;
      miniature.onTap();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(VideoExpanded), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SingleChoiceForm), findsOneWidget);
    });
  });
}

VideoMiniature get _miniatureWidget => find
    .byType(VideoMiniature)
    .evaluate() //
    .first
    .widget as VideoMiniature;
