import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal/expanded/video_expanded.dart';
import 'package:pal/pal.dart';
import 'package:pal/surveys/single_choice/single_choice.dart';

void main() {
  group('miniature > video > single choice', () {
    BuildContext? _context;

    Future beforeEach(WidgetTester tester) async {
      var app = MaterialApp(
        home: Builder(builder: (context) {
          _context = context;
          return Scaffold(
            body: Container(),
          );
        }),
      );
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 500));
      expect(_context, isNotNull);
      // show a single choice video
      PalPlugin.instance.showSingleChoiceSurvey(
        context: _context!,
        videoAsset: 'assets/me.mp4',
        userName: 'Gautier',
        companyTitle: 'Apparence.io CTO',
        question: 'my question lorem ipsum lorem',
        choices: const [
          Choice(id: 'a', text: 'lorem A'),
          Choice(id: 'b', text: 'lorem B'),
          Choice(id: 'c', text: 'lorem C'),
          Choice(id: 'd', text: 'lorem D'),
        ],
        onTapChoice: (choice) {},
        onVideoEndAction: () {},
      );
    }

    testWidgets('Pal instance exists', (WidgetTester tester) async {
      await beforeEach(tester);
      expect(PalPlugin.instance, isNotNull);
    });

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
      expect(find.byType(SingleChoiceForm), findsOneWidget);
    });
  });
}

VideoMiniature get _miniatureWidget => find
    .byType(VideoMiniature)
    .evaluate() //
    .first
    .widget as VideoMiniature;
