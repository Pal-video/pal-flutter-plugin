import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pal_video/api/http_client.dart';
import 'package:pal_video/api/models/author.dart';
import 'package:pal_video/api/models/video_trigger.dart';
import 'package:pal_video/miniature/video_miniature.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_utils.dart';

class BuildContextMock extends Mock implements BuildContext {}

class HttpClientMock extends Mock implements HttpClient {}

class SharedPreferencesMock extends Mock implements SharedPreferences {}

void main() {
  final HttpClient httpClient = HttpClientMock();

  final SharedPreferences sharedPreferencesMock = SharedPreferencesMock();

  GlobalKey<NavigatorState>? navigatorKey;

  MaterialApp? app;

  Future createApp(WidgetTester tester) async {
    navigatorKey = GlobalKey<NavigatorState>();
    when(() => sharedPreferencesMock.getString('sessionId'))
        .thenReturn('803238203D');
    app = await createAppWithPal(
      httpClient: httpClient,
      sharedPreferencesMock: sharedPreferencesMock,
      navigatorKey: navigatorKey,
    );
  }

  tearDown(() {
    reset(httpClient);
    reset(sharedPreferencesMock);
  });

  setUpAll(() {
    registerFallbackValue(BuildContextMock());
    registerFallbackValue(Uri.parse('/eventlogs'));
  });

  Future<void> startApp(WidgetTester tester) async {
    await tester.pumpWidget(app!);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }

  testWidgets(
    '''
    call setCurrentScreen, api returns no action to perform
    => shows nothing 
    ''',
    (WidgetTester tester) async {
      await createApp(tester);
      when(() => httpClient.post(
            any(),
            body: any(named: 'body'),
          )).thenAnswer((_) => Future.value(Response(
            '',
            200,
          )));
      await startApp(tester);

      expect(find.byType(VideoMiniature), findsNothing);
    },
  );

  testWidgets(
    '''start app on home page, shows a video, replace page with page 1 
    => palPlugin remove video from screen''',
    (WidgetTester tester) async {
      await createApp(tester);
      PalVideoTrigger videoTriggerResponse = _createVideoOnlyAnswer();
      when(() => httpClient.post(
            any(),
            body: any(named: 'body'),
          )).thenAnswer((_) => Future.value(Response(
            videoTriggerResponse.toJson(),
            200,
          )));
      await startApp(tester);
      expect(find.byType(VideoMiniature), findsOneWidget);

      when(() => httpClient.post(
            any(),
            body: any(named: 'body'),
          )).thenAnswer((_) => Future.value(Response('', 200)));
      navigatorKey!.currentState!.pushReplacementNamed('/page1');
      await tester.pumpAndSettle();

      expect(find.text('page 1'), findsOneWidget);
      var captured = verify(
        () => httpClient.post(
          any(),
          body: captureAny(named: 'body'),
        ),
      ).captured;
      expect(captured.length, 2);
      expect(find.byType(VideoMiniature), findsNothing);
    },
  );

  // testWidgets(
  //   '''
  //   call setCurrentScreen with name screen1, sessionUID
  //   => send a PalEvent with all attributes
  //   ''',
  //   (WidgetTester tester) async {
  //     await _createApp(tester);
  //     PalVideoTrigger videoTriggerResponse =
  //         _createVideoOnlyAnswer(eventLogId: '9830203DJFB');
  //     // mock the triggering video call
  //     when(
  //       () => httpClient.post(
  //         Uri.parse('/eventlogs'),
  //         body: any(named: 'body'),
  //       ),
  //     ).thenAnswer(
  //       (_) => Future.value(Response(videoTriggerResponse.toJson(), 200)),
  //     );
  //     // mock the anayltics call
  //     when(
  //       () => httpClient.post(
  //         Uri.parse('/eventlogs/9830203DJFB'),
  //         body: any(named: 'body'),
  //       ),
  //     ).thenAnswer(
  //       (_) => Future.value(Response('', 200)),
  //     );
  //     await _startApp(tester);

  //     final capturedCall = verify(() => httpClient.post(
  //           Uri.parse('/eventlogs/9830203DJFB'),
  //           body: captureAny(named: "body"),
  //         )).captured;
  //     // should send 3 pal events :
  //     // 1 - the video trigger,
  //     // 2 - the video is opened
  //     // 3 - the video has been viewed
  //     expect(capturedCall.length, 3);
  //   },
  // );
}

class FakePage extends StatelessWidget {
  final String title;

  const FakePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(title)),
    );
  }
}

PalVideoTrigger _createVideoOnlyAnswer({String? eventLogId}) {
  final videoTriggerResponse = PalVideoTrigger(
    eventLogId: eventLogId ?? '3682638A',
    videoId: 'videoId98309283',
    creationDate: DateTime.now(),
    // type: PalVideos.,
    videoUrl: 'http://240purl.com',
    videoThumbUrl: 'http://480purl.com',
    imgThumbUrl: 'http://720purl.com',
    author: Author(
      companyTitle: 'CEO',
      userName: 'John Mclane',
    ),
  );
  return videoTriggerResponse;
}
