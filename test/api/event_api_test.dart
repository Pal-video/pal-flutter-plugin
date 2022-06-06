import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pal/api/models/author.dart';
import 'package:pal/api/models/event.dart';
import 'package:pal/api/http_client.dart';
import 'package:pal/api/models/pal_options.dart';
import 'package:pal/api/models/session.dart';
import 'package:pal/api/models/survey.dart';
import 'package:pal/api/models/video_trigger.dart';
import 'package:pal/api/models/video_trigger_event.dart';
import 'package:pal/api/pal.dart';
import 'package:pal/api/session_api.dart';
import 'package:pal/pal.dart';
// import 'package:pal/surveys/single_choice/single_choice.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_utils.dart';
import 'event_api_test.mocks.dart';

@GenerateMocks([HttpClient, SharedPreferences])
void main() {
  group(''' 
  sessionApi doesn't have any locally saved session
  ''', () {
    late Pal pal;
    HttpClient httpClient = MockHttpClient();
    SharedPreferences sharedPreferencesMock = MockSharedPreferences();

    /// in real code use Pal.instance.initialize(PalOptions(apiKey: "apiKey"));
    void beforeEach() {
      pal = Pal(
          httpClient: httpClient,
          sdk: PalSdk.instance,
          sessionApi: PalSessionApi(httpClient, sharedPreferencesMock));
    }

    tearDown(() {
      reset(httpClient);
      reset(sharedPreferencesMock);
    });

    testWidgets(
      '''
      should create a session from remote server,
      session is saved in sharedpreferences
      ''',
      (WidgetTester tester) async {
        when(httpClient.post(
          Uri.parse('/sessions'),
          body: anyNamed('body'),
        )).thenAnswer((_) => Future.value(
              Response(
                '{"uid": "803238203D"}',
                200,
              ),
            ));
        when(sharedPreferencesMock.getString('sessionId')).thenReturn(null);
        when(sharedPreferencesMock.setString('sessionId', '803238203D'))
            .thenAnswer((_) => Future.value(true));
        beforeEach();
        await pal.initialize(PalOptions(apiKey: 'apiKey'));

        final createSession = verify(httpClient.post(
          Uri.parse('/sessions'),
          body: captureAnyNamed('body'),
        )).captured;
        verify(sharedPreferencesMock.getString('sessionId')).called(1);
        verify(sharedPreferencesMock.setString('sessionId', '803238203D'))
            .called(1);
        final createSessionReq =
            PalSessionRequest.fromMap(jsonDecode(createSession[0]));
        // session creation embedd current client context
        expect(createSessionReq.frameworkType, "FLUTTER");
        expect(createSessionReq.platform, "android");
      },
    );
  });

  group(''' 
    init session returns a sessionId from localstorage
    ''', () {
    late Pal pal;
    HttpClient httpClient = MockHttpClient();
    SharedPreferences sharedPreferencesMock = MockSharedPreferences();

    /// in real code use Pal.instance.initialize(PalOptions(apiKey: "apiKey"));
    void beforeEach() {
      when(sharedPreferencesMock.getString('sessionId'))
          .thenReturn('803238203D');

      pal = Pal(
          httpClient: httpClient,
          sdk: PalSdk.instance,
          sessionApi: PalSessionApi(httpClient, sharedPreferencesMock))
        ..initialize(PalOptions(apiKey: 'apiKey'));
    }

    tearDown(() {
      reset(httpClient);
      reset(sharedPreferencesMock);
    });

    testWidgets(
      '''
    call setCurrentScreen with name screen1, sessionUID
    => send a PalEvent with all attributes
    ''',
      (WidgetTester tester) async {
        beforeEach();
        when(httpClient.post(Uri.parse('/eventlogs'), body: anyNamed('body')))
            .thenAnswer((_) => Future.value(Response('', 200)));
        var app = MaterialApp(
          home: Builder(builder: (context) {
            pal.logCurrentScreen(context, 'screen1');
            return Scaffold(
              body: Container(),
            );
          }),
        );
        await tester.pumpWidget(app);
        await tester.pump(const Duration(milliseconds: 100));

        final capturedCall = verify(httpClient.post(
          Uri.parse('/eventlogs'),
          body: captureAnyNamed("body"),
        )).captured;
        final captureEvent = capturedCall[0];
        final capturedPalEvent = jsonDecode(captureEvent);
        expect(capturedPalEvent['name'], equals('screen1'));
        expect(capturedPalEvent['sessionUId'], equals('803238203D'));
        expect(capturedPalEvent['type'], equals(PalEvents.setScreen.name));
        expect(
          capturedPalEvent['attrs'],
          equals(
            jsonEncode(<String, dynamic>{
              "name": "screen1",
            }),
          ),
        );
      },
    );

    testWidgets(
      '''
    call setCurrentScreen, api returns no action to perform
    => shows nothing 
    ''',
      (WidgetTester tester) async {
        beforeEach();
        when(httpClient.post(Uri.parse('/eventlogs'), body: anyNamed('body')))
            .thenAnswer((_) => Future.value(Response('', 200)));
        var app = MaterialApp(
          home: Builder(builder: (context) {
            pal.logCurrentScreen(context, 'screen1');
            return Scaffold(
              body: Container(),
            );
          }),
        );
        await tester.pumpWidget(app);
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(VideoMiniature), findsNothing);
      },
    );

    testWidgets(
      '''
    call setCurrentScreen, api returns error
    => shows nothing 
    ''',
      (WidgetTester tester) async {
        beforeEach();
        when(httpClient.post(Uri.parse('/eventlogs'), body: anyNamed('body')))
            .thenAnswer((_) => Future.value(Response('', 500)));
        var app = MaterialApp(
          home: Builder(builder: (context) {
            pal.logCurrentScreen(context, 'screen1');
            return Scaffold(
              body: Container(),
            );
          }),
        );
        await tester.pumpWidget(app);
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(VideoMiniature), findsNothing);
      },
    );

    testWidgets(
      '''
    call setCurrentScreen, api returns a Video with a singleChoice form
    => calls PalPlugin showSingleChoiceSurvey. 
    ''',
      (WidgetTester tester) async {
        beforeEach();
        PalVideoTrigger videoTriggerResponse = _createVideoWithSurvey();
        when(httpClient.post(
          Uri.parse('/eventlogs'),
          body: anyNamed('body'),
        )).thenAnswer((_) => Future.value(
              Response(
                videoTriggerResponse.toJson(),
                200,
              ),
            ));
        var app = MaterialApp(
          home: Builder(builder: (context) {
            pal.logCurrentScreen(context, 'screen1');
            return Scaffold(
              body: Container(),
            );
          }),
        );
        await tester.pumpWidget(app);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(VideoMiniature), findsOneWidget);
      },
    );

    testWidgets(
      '''
    call setCurrentScreen, shows a single choice survey, push skip
    => calls api to record [open video, skipped event]
    ''',
      (WidgetTester tester) async {
        beforeEach();
        PalVideoTrigger videoTriggerResponse = _createVideoWithSurvey();
        when(httpClient.post(
          Uri.parse('/eventlogs'),
          body: anyNamed('body'),
        )).thenAnswer((_) => Future.value(Response(
              videoTriggerResponse.toJson(),
              200,
            )));
        when(httpClient.post(
          Uri.parse('/eventlogs/${videoTriggerResponse.eventLogId}'),
          body: anyNamed('body'),
        )).thenAnswer((_) => Future.value(Response('', 200)));
        var app = MaterialApp(
          home: Builder(builder: (context) {
            pal.logCurrentScreen(context, 'screen1');
            return Scaffold(
              body: Container(),
            );
          }),
        );
        await tester.pumpWidget(app);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(VideoMiniature), findsOneWidget);
        final miniatureWidget = findWidget<VideoMiniature>();
        miniatureWidget.onTap();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byKey(const ValueKey("palVideoSkip")), findsOneWidget);
        final skipBtn = findWidget<ElevatedButton>();
        skipBtn.onPressed!();
        await tester.pump(const Duration(milliseconds: 500));
        final capturedCall = verify(httpClient.post(
          Uri.parse('/eventlogs/3682638A'),
          body: captureAnyNamed("body"),
        )).captured;
        final resultEvents = capturedCall[0] as List<dynamic>;
        expect(resultEvents, isNotNull);
        expect(resultEvents.length, 2);
        final event_1 = VideoTriggerEvent.fromJson(resultEvents[0]);
        final event_2 = VideoTriggerEvent.fromJson(resultEvents[1]);
        expect(event_1.type, VideoTriggerEvents.minVideoOpen);
        expect(event_1.time, isNotNull);
        expect(event_2.type, VideoTriggerEvents.videoSkip);
        expect(event_2.time, isNotNull);
      },
    );

// NO survey for now
//     testWidgets(
//       '''
//     call setCurrentScreen, shows a single choice survey with 3 choices,
//     user push choice a
//     => calls api to record [open video, choice with a]
//     ''',
//       (WidgetTester tester) async {
//         beforeEach();
//         PalVideoTrigger videoTriggerResponse = _createVideoWithSurvey();
//         when(httpClient.post(
//           Uri.parse('/events'),
//           body: anyNamed('body'),
//         )).thenAnswer((_) => Future.value(Response(
//               videoTriggerResponse.toJson(),
//               200,
//             )));
//         when(httpClient.post(
//           Uri.parse('/triggers/${videoTriggerResponse.id}'),
//           body: anyNamed('body'),
//         )).thenAnswer((_) => Future.value(Response('', 200)));
//         var app = MaterialApp(
//           home: Builder(builder: (context) {
//             pal.logCurrentScreen(context, 'screen1');
//             return Scaffold(
//               body: Container(),
//             );
//           }),
//         );
//         await tester.pumpWidget(app);
//         await tester.pump(const Duration(milliseconds: 500));
//         await tester.pump(const Duration(milliseconds: 500));
//         expect(find.byType(VideoMiniature), findsOneWidget);
//         final miniatureWidget = findWidget<VideoMiniature>();
//         miniatureWidget.onTap();
//         await tester.pump(const Duration(milliseconds: 500));
//         await tester.pump(const Duration(milliseconds: 500));
//         await tester.pump(const Duration(milliseconds: 500));
//         expect(find.byType(ChoiceWidget), findsNWidgets(3));
//         await tester.tap(find.byType(ChoiceWidget).first);
//         await tester.pump(const Duration(milliseconds: 500));
//         await tester.pump(const Duration(milliseconds: 500));

//         final capturedCall = verify(httpClient.post(
//           Uri.parse('/triggers/3682638A'),
//           body: captureAnyNamed("body"),
//         )).captured;
//         final resultEvents = capturedCall[0] as List<dynamic>;
//         expect(resultEvents, isNotNull);
//         expect(resultEvents.length, 2);
//         final event_1 = VideoTriggerEvent.fromJson(resultEvents[0]);
//         final event_2 = VideoTriggerEvent.fromJson(resultEvents[1]);
//         expect(event_1.type, VideoTriggerEvents.minVideoOpen);
//         expect(event_1.sessionId, '803238203D');
//         expect(event_2.type, VideoTriggerEvents.answer);
//         expect(event_2.args!['answer'], 'a');
//         expect(event_2.sessionId, '803238203D');
//       },
//     );
  });
}

PalVideoTrigger _createVideoWithSurvey() {
  final videoTriggerResponse = PalVideoTrigger(
    eventLogId: '3682638A',
    videoId: 'videoId98309283',
    creationDate: DateTime.now(),
    // type: PalVideos.survey,
    videoUrl: 'http://240purl.com',
    videoThumbUrl: 'http://480purl.com',
    imgThumbUrl: 'http://720purl.com',
    author: Author(
      companyTitle: 'CEO',
      userName: 'John Mclane',
    ),
    survey: Survey(question: '', choices: [
      ChoiceItem(id: 'a', text: 'réponse a'),
      ChoiceItem(id: 'b', text: 'réponse b'),
      ChoiceItem(id: 'c', text: 'réponse c'),
    ]),
  );
  return videoTriggerResponse;
}

PalVideoTrigger _createVideoOnlyAnswer() {
  final videoTriggerResponse = PalVideoTrigger(
    eventLogId: '3682638A',
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
