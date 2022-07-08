import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pal/expanded/video_expanded.dart';
import 'package:video_player/video_player.dart';

import 'expanded_video_test.mocks.dart';

@GenerateMocks([VideoPlayerController])
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
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
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
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('onSkip is not visible', (WidgetTester tester) async {
      await beforeEach(tester);
      expect(find.byType(ElevatedButton), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
    });
  });

  group('onSkip', () {
    bool hasEnd = false;
    var videoController = MockVideoPlayerController();

    Future beforeEach(WidgetTester tester) async {
      var app = MaterialApp(
        home: Scaffold(
          body: VideoExpanded(
            videoPlayerController: videoController,
            videoAsset: 'assets/me.mp4',
            onSkip: () => {},
            companyTitle: "CEO",
            userName: 'Marty Mcfly',
            onEndAction: () => hasEnd = true,
            testMode: true,
          ),
        ),
      );
      // mock video controller
      final realVideoController = VideoPlayerController.asset('');
      when(videoController.value).thenAnswer((_) => realVideoController.value);
      // pump app
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('onSkip is visible, skip text is visible',
        (WidgetTester tester) async {
      await beforeEach(tester);
      expect(find.byKey(const ValueKey("palVideoSkip")), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('volume is at 100, looping is false',
        (WidgetTester tester) async {
      await beforeEach(tester);
      await tester.pump();
      final videoExpandedState =
          tester.state<VideoExpandedState>(find.byType(VideoExpanded));
      final videoController = videoExpandedState.videoPlayerController;

      expect(videoController!.value.volume, 1.0);
      expect(videoController.value.isLooping, isFalse);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
    });

    // we replaced this with a stopwatch since getting position creates lag
    // testWidgets(
    //     'trigger is called 0s before the end of the vidéo => endActionIsCalled',
    //     (WidgetTester tester) async {
    //   await beforeEach(tester);
    //   final videoExpandedState =
    //       tester.state<VideoExpandedState>(find.byType(VideoExpanded));

    //   when(videoExpandedState.videoPlayerController!.position)
    //       .thenAnswer((_) => Future.value(Duration.zero));
    //   videoExpandedState.videoListener.onPositionChangedListener();

    //   await tester.pump();
    //   expect(hasEnd, isTrue);
    //   await tester.pump(const Duration(milliseconds: 500));
    //   await tester.pump(const Duration(milliseconds: 500));
    //   await tester.pump(const Duration(milliseconds: 500));
    // });
  });
}
