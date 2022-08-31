import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pal_video/api/session_api.dart';
import 'package:pal_video/pal.dart';
import 'package:pal_video/api/http_client.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesMock extends Mock implements SharedPreferences {}

createAppWithPal({
  required HttpClient httpClient,
  required SharedPreferences sharedPreferencesMock,
  GlobalKey<NavigatorState>? navigatorKey,
}) async {
  var pal = Pal(
    httpClient: httpClient,
    sessionApi: PalSessionApi(httpClient, sharedPreferencesMock),
  );
  navigatorKey ??= GlobalKey<NavigatorState>();
  var palNavigatorObserver = PalNavigatorObserver(pal: pal);
  await pal.initialize(PalOptions(apiKey: 'apiKey'), navigatorKey);

  return MaterialApp(
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

T findWidget<T>() => find
    .byType(T)
    .evaluate() //
    .first
    .widget as T;

T findNWidget<T>(int n) => find
    .byType(T)
    .evaluate() //
    .toList()
    .elementAt(n)
    .widget as T;

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
