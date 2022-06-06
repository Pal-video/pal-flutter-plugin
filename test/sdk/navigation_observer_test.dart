import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pal/api/pal.dart';
import 'package:pal/sdk/navigation_observer.dart';

class PalMock extends Mock implements Pal {}

class BuildContextMock extends Mock implements BuildContext {}

void main() {
  final palMock = PalMock();

  final palNavigatorObserver = PalNavigatorObserver(pal: palMock);

  final navigatorKey = GlobalKey<NavigatorState>();

  MaterialApp? app;

  Future _createApp(WidgetTester tester) async {
    reset(palMock);
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

  setUpAll(() {
    registerFallbackValue(BuildContextMock());
  });

  Future<void> _startApp(WidgetTester tester) async {
    await tester.pumpWidget(app!);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'start app on home page => palPlugin call log SetScreen',
    (WidgetTester tester) async {
      await _createApp(tester);
      when(() => palMock.logCurrentScreen(any(), captureAny())).thenAnswer(
        (_) async {},
      );
      await _startApp(tester);
      expect(app, isNotNull);

      expect(find.text('home page'), findsOneWidget);
      var captured =
          verify(() => palMock.logCurrentScreen(any(), captureAny())).captured;
      expect(captured.isNotEmpty, isTrue);
      expect(captured.length, 1);
      expect(captured.last[0], '/');
    },
  );

  testWidgets(
    '''start app on home page, move to page 1, then page 2 
    => palPlugin call log SetScreen 3 times with different routes''',
    (WidgetTester tester) async {
      await _createApp(tester);
      when(() => palMock.logCurrentScreen(any(), captureAny())).thenAnswer(
        (_) async {},
      );
      await _startApp(tester);
      navigatorKey.currentState!.pushNamed('/page1');
      await tester.pumpAndSettle();
      navigatorKey.currentState!.pushNamed('/page2');
      await tester.pumpAndSettle();

      expect(find.text('page 2'), findsOneWidget);
      var captured =
          verify(() => palMock.logCurrentScreen(any(), captureAny())).captured;
      expect(captured.isNotEmpty, isTrue);
      expect(captured.length, 3);
      expect(captured, ['/', '/page1', '/page2']);
    },
  );

  testWidgets(
    '''start app on home page, replace page with page 1 
    => palPlugin call log SetScreen 2 times with different routes''',
    (WidgetTester tester) async {
      await _createApp(tester);
      when(() => palMock.logCurrentScreen(any(), captureAny())).thenAnswer(
        (_) async {},
      );
      await _startApp(tester);
      navigatorKey.currentState!.pushReplacementNamed('/page1');
      await tester.pumpAndSettle();

      expect(find.text('page 1'), findsOneWidget);
      var captured =
          verify(() => palMock.logCurrentScreen(any(), captureAny())).captured;
      expect(captured.isNotEmpty, isTrue);
      expect(captured.length, 2);
      expect(captured, ['/', '/page1']);
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
