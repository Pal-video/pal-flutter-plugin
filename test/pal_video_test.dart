import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pal/api/http_client.dart';
import 'package:pal/api/models/author.dart';
import 'package:pal/api/models/pal_options.dart';
import 'package:pal/api/models/video_trigger.dart';
import 'package:pal/api/pal.dart';
import 'package:pal/api/session_api.dart';
import 'package:pal/sdk/navigation_observer.dart';
import 'package:pal/sdk/pal_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuildContextMock extends Mock implements BuildContext {}

class HttpClientMock extends Mock implements HttpClient {}

class SharedPreferencesMock extends Mock implements SharedPreferences {}

void main() {
  final HttpClient httpClient = HttpClientMock();

  final SharedPreferences sharedPreferencesMock = SharedPreferencesMock();

  late final Pal pal;

  late final PalNavigatorObserver palNavigatorObserver;

  GlobalKey<NavigatorState>? navigatorKey;

  MaterialApp? app;

  Future _createApp(WidgetTester tester) async {
    navigatorKey = GlobalKey<NavigatorState>();
    // init pal
    pal = Pal(
      httpClient: httpClient,
      sessionApi: PalSessionApi(httpClient, sharedPreferencesMock),
    );
    palNavigatorObserver = PalNavigatorObserver(pal: pal);
    when(() => sharedPreferencesMock.getString('sessionId'))
        .thenReturn('803238203D');
    await pal.initialize(PalOptions(apiKey: 'apiKey'), navigatorKey!);
    // create app
    app = MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [palNavigatorObserver],
      initialRoute: '/',
      routes: {
        '/': (context) => const FakePage(title: 'home page'),
        '/page1': (context) => const FakePage(title: 'page 1'),
        '/page2': (context) => const FakePage(title: 'page 2'),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashFactory: InkSplash.splashFactory,
      ),
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

  Future<void> _startApp(WidgetTester tester) async {
    await tester.pumpWidget(app!);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }

  testWidgets(
    '''start app on home page, shows a video, replace page with page 1 
    => palPlugin don't call eventlogs api as a video is already present''',
    (WidgetTester tester) async {
      await _createApp(tester);
      PalVideoTrigger videoTriggerResponse = _createVideoOnlyAnswer();
      when(() => httpClient.post(
            any(),
            body: any(named: 'body'),
          )).thenAnswer((_) => Future.value(Response(
            videoTriggerResponse.toJson(),
            200,
          )));
      await _startApp(tester);
      navigatorKey!.currentState!.pushReplacementNamed('/page1');
      await tester.pumpAndSettle();

      expect(find.text('page 1'), findsOneWidget);
      var captured = verify(
        () => httpClient.post(
          any(),
          body: captureAny(named: 'body'),
        ),
      ).captured;
      expect(captured.length, 1);
    },
  );
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
