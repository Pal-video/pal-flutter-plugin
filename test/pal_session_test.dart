import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pal/api/http_client.dart';
import 'package:pal/api/models/pal_options.dart';
import 'package:pal/api/models/session.dart';
import 'package:pal/api/pal.dart';
import 'package:pal/api/session_api.dart';
import 'package:pal/pal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/event_api_test.mocks.dart';

@GenerateMocks([HttpClient, SharedPreferences])
void main() {
  group(''' 
  sessionApi doesn't have any locally saved session
  ''', () {
    late Pal pal;

    HttpClient httpClient = MockHttpClient();

    SharedPreferences sharedPreferencesMock = MockSharedPreferences();

    final navigatorKey = GlobalKey<NavigatorState>();

    /// in real code use Pal.instance.initialize(PalOptions(apiKey: "apiKey"));
    void beforeEach() {
      pal = Pal(
          httpClient: httpClient,
          sdk: PalSdk.fromKey(navigatorKey: navigatorKey),
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
        // when(sharedPreferencesMock.getString('sessionId')).thenReturn(null);
        when(sharedPreferencesMock.setString('sessionId', '803238203D'))
            .thenAnswer((_) => Future.value(true));
        beforeEach();
        await pal.initialize(PalOptions(apiKey: 'apiKey'), navigatorKey);

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

  group('user has a stored session', () {
    late Pal pal;

    HttpClient httpClient = MockHttpClient();

    final navigatorKey = GlobalKey<NavigatorState>();

    SharedPreferences sharedPreferencesMock = MockSharedPreferences();

    Future<void> beforeEach() async {
      pal = Pal(
          httpClient: httpClient,
          sdk: PalSdk.fromKey(navigatorKey: navigatorKey),
          sessionApi: PalSessionApi(httpClient, sharedPreferencesMock));
      // create a session mock request
      when(httpClient.post(
        Uri.parse('/sessions'),
        body: anyNamed('body'),
      )).thenAnswer((_) => Future.value(
            Response(
              '{"uid": "803238203D"}',
              200,
            ),
          ));
      // call create session
      await pal.initialize(PalOptions(apiKey: 'apiKey'), navigatorKey);
    }

    tearDown(() {
      reset(httpClient);
      reset(sharedPreferencesMock);
    });

    testWidgets(
      '''
      create a remote session and save it in sharedpreferences
      call reset session => session is removed from sharedpreferences
      ''',
      (WidgetTester tester) async {
        // init pal
        await beforeEach();

        // call reset session
        await pal.resetSession();
        verify(sharedPreferencesMock.clear()).called(1);
      },
    );
  });
}
