import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal/expanded/video_expanded.dart';
import 'package:pal/miniature/video_miniature.dart';
import 'package:pal/sdk/pal_plugin.dart';

void main() {
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
  }

  testWidgets('Pal instance exists', (WidgetTester tester) async {
    await beforeEach(tester);
    expect(PalPlugin.instance, isNotNull);
  });

  testWidgets('call showVideoAsset => shows a video within miniature',
      (WidgetTester tester) async {
    await beforeEach(tester);
    await PalPlugin.instance.showVideoAsset(
      context: _context!,
      videoAsset: 'assets/me.mp4',
      userName: 'Gautier',
      companyTitle: 'Apparence.io CTO',
      onVideoEndAction: () {},
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(VideoMiniature), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets(
      'call showVideoAsset, tap on miniature => expanded video is shown',
      (WidgetTester tester) async {
    await beforeEach(tester);
    await PalPlugin.instance.showVideoAsset(
      context: _context!,
      videoAsset: 'assets/me.mp4',
      userName: 'Gautier',
      companyTitle: 'Apparence.io CTO',
      onVideoEndAction: () {},
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.ensureVisible(find.byType(VideoMiniature));
    final miniature =
        find.byType(VideoMiniature).evaluate().first.widget as VideoMiniature;
    miniature.onTap();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(VideoExpanded), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
