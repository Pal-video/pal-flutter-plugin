import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal/expanded/video_expanded.dart';
import 'package:pal/miniature/video_miniature.dart';
import 'package:pal/sdk/pal_sdk.dart';

import '../test_utils.dart';

void main() {
  final navigatorKey = GlobalKey<NavigatorState>();

  PalSdk palSdk = PalSdk.fromKey(navigatorKey: navigatorKey);

  Future beforeEach(WidgetTester tester) async {
    var app = MaterialApp(
      navigatorKey: navigatorKey,
      home: Builder(builder: (context) {
        return Scaffold(
          body: Container(),
        );
      }),
    );
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 500));
    expect(navigatorKey.currentState?.context, isNotNull,
        reason: 'context is not null');
  }

  testWidgets('Create new Pal works', (WidgetTester tester) async {
    await beforeEach(tester);
    expect(PalSdk.fromKey(navigatorKey: navigatorKey), isNotNull);
  });

  testWidgets('call showVideoAsset => shows a video within miniature',
      (WidgetTester tester) async {
    await beforeEach(tester);
    await palSdk.showVideoAsset(
      context: navigatorKey.currentState!.context,
      videoAsset: 'assets/me.mp4',
      userName: 'Gautier',
      companyTitle: 'Apparence.io CTO',
      animateOnVideoEnd: false,
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
    await palSdk.showVideoAsset(
      context: navigatorKey.currentContext!,
      videoAsset: 'assets/me.mp4',
      userName: 'Gautier',
      companyTitle: 'Apparence.io CTO',
      animateOnVideoEnd: false,
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

  testWidgets(
      'call showVideoOnly, tap on miniature => expanded video is shown then closed',
      (WidgetTester tester) async {
    await beforeEach(tester);
    await palSdk.showVideoOnly(
      context: navigatorKey.currentContext!,
      videoUrl: 'assets/me.mp4',
      minVideoUrl: 'assets/minme.mp4',
      userName: 'Gautier',
      companyTitle: 'Apparence.io CTO',
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.ensureVisible(find.byType(VideoMiniature));
    final miniature = findWidget<VideoMiniature>();
    miniature.onTap();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(VideoExpanded), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
