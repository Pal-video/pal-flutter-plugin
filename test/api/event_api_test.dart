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
import 'package:pal/api/models/survey.dart';
import 'package:pal/api/models/video_trigger.dart';
import 'package:pal/api/pal.dart';
import 'package:pal/pal.dart';

import 'event_api_test.mocks.dart';

@GenerateMocks([HttpClient])
void main() {
  late Pal pal;
  HttpClient httpClient = MockHttpClient();

  /// in real code use Pal.instance.initialize(PalOptions(apiKey: "apiKey"));
  void beforeEach() {
    pal = Pal(
      httpClient: httpClient,
      sdk: PalPlugin.instance,
    )..initialize(PalOptions(apiKey: 'apiKey'));
  }

  tearDown(() {
    reset(httpClient);
  });

  testWidgets(
    '''
    call setCurrentScreen with name screen1
    => send a PalEvent with all attributes
    ''',
    (WidgetTester tester) async {
      beforeEach();
      when(httpClient.post(Uri.parse('/events'), body: anyNamed('body')))
          .thenAnswer((_) => Future.value(Response('', 200))); //FIXME
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
        Uri.parse('/events'),
        body: captureAnyNamed("body"),
      )).captured;
      final captureEvent = capturedCall[0];
      expect(captureEvent['event'], equals(PalEvents.setScreen.name));
      expect(captureEvent['platform'], equals('android'));
      expect(
        captureEvent['attrs'],
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
      when(httpClient.post(Uri.parse('/events'), body: anyNamed('body')))
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
      when(httpClient.post(Uri.parse('/events'), body: anyNamed('body')))
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
      final videoTriggerResponse = PalVideoTrigger(
        id: '3682638A',
        type: PalVideos.survey,
        video240pUrl: 'http://240purl.com',
        video480pUrl: 'http://480purl.com',
        video720pUrl: 'http://720purl.com',
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
      when(httpClient.post(
        Uri.parse('/events'),
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
    => calls api to record skipped event
    ''',
    (WidgetTester tester) async {
      beforeEach();
      final videoTriggerResponse = PalVideoTrigger(
        id: '3682638A',
        type: PalVideos.survey,
        video240pUrl: 'http://240purl.com',
        video480pUrl: 'http://480purl.com',
        video720pUrl: 'http://720purl.com',
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
      when(httpClient.post(
        Uri.parse('/events'),
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

      final skipBtnFinder = find.byKey(const ValueKey("palVideoSkip"));
      await tester.tap(skipBtnFinder);
      await tester.pump(const Duration(milliseconds: 500));
      final capturedCall = verify(httpClient.post(
        Uri.parse('/triggers/3682638A'),
        body: captureAnyNamed("body"),
      )).captured;
      capturedCall[0];
    },
  );
}
