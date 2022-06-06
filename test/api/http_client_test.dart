import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pal/api/http_client.dart';

import 'http_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('HttpClient tests with token', () {
    var httpMockClient = MockClient();

    var baseUrl = 'baseUrl';
    HttpClient httpClient = HttpClient.internal(
      baseUrl,
      'JLKJDLSJDLKSJDLSD',
      httpClient: httpMockClient,
    );

    setUp(() {
      reset(httpMockClient);
    });

    testWidgets(
        'GET, returning code 200 => sends request with token on correct url',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        when(httpMockClient.send(any)).thenAnswer((_) =>
            Future<http.StreamedResponse>(() => http.StreamedResponse(
                Stream.fromFuture(Future<List<int>>(() => [])), 200)));
        var res = await httpClient.get(Uri.parse('/test'));
        expect(res.statusCode, 200);
        var capturedCall = verify(httpMockClient.send(captureAny)).captured;
        expect(capturedCall[0].url.toString(), equals('$baseUrl/test'));
        expect(
          capturedCall[0].headers['Authorization'],
          equals('Bearer JLKJDLSJDLKSJDLSD'),
        );
      });
    });

    testWidgets(
        'POST, returning code 200 => sends request with token on correct url',
        (WidgetTester tester) async {
      await tester.runAsync(
        () async {
          when(httpMockClient.send(any)).thenAnswer((_) =>
              Future<http.StreamedResponse>(() => http.StreamedResponse(
                  Stream.fromFuture(Future<List<int>>(() => [])), 200)));
          var res = await httpClient.post(Uri.parse('/test'));
          expect(res.statusCode, 200);

          var capturedCall = verify(httpMockClient.send(captureAny)).captured;
          expect(capturedCall[0].url.toString(), equals('$baseUrl/test'));
          expect(
            capturedCall[0].headers['Authorization'],
            equals('Bearer JLKJDLSJDLKSJDLSD'),
          );
        },
      );
    });

    testWidgets(
      'PUT, returning code 200 => sends request with token on correct url',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          when(httpMockClient.send(any)).thenAnswer((_) =>
              Future<http.StreamedResponse>(() => http.StreamedResponse(
                  Stream.fromFuture(Future<List<int>>(() => [])), 200)));
          var res = await httpClient.put(Uri.parse('/test'));
          expect(res.statusCode, 200);

          var capturedCall = verify(httpMockClient.send(captureAny)).captured;
          expect(capturedCall[0].url.toString(), equals('$baseUrl/test'));
          expect(
            capturedCall[0].headers['Authorization'],
            equals('Bearer JLKJDLSJDLKSJDLSD'),
          );
        });
      },
    );

    testWidgets(
        'DELETE, returning code 200 => sends request with token on correct url',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        when(httpMockClient.send(any)).thenAnswer((_) =>
            Future<http.StreamedResponse>(() => http.StreamedResponse(
                Stream.fromFuture(Future<List<int>>(() => [])), 200)));
        var res = await httpClient.delete(Uri.parse('/test'));
        expect(res.statusCode, 200);

        var capturedCall = verify(httpMockClient.send(captureAny)).captured;
        expect(capturedCall[0].url.toString(), equals('$baseUrl/test'));
        expect(
          capturedCall[0].headers['Authorization'],
          equals('Bearer JLKJDLSJDLKSJDLSD'),
        );
      });
    });

    testWidgets('http 500 should throw InternalHttpError',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        when(httpMockClient.send(any)).thenAnswer(
          (_) => Future<http.StreamedResponse>(
            () => http.StreamedResponse(
              Stream.fromFuture(Future<List<int>>(() => [])),
              500,
            ),
          ),
        );
        try {
          await httpClient.get(Uri.parse('/test'));
          expect(false, true);
        } catch (e) {
          expect(e is InternalHttpError, equals(true),
              reason: 'e is InternalHttpError');
        }
      });
    });

    testWidgets('http 400 should throw UnreacheableHttpError',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        when(httpMockClient.send(any)).thenAnswer(
          (_) => Future<http.StreamedResponse>(
            () => http.StreamedResponse(
              Stream.fromFuture(Future<List<int>>(() => [])),
              400,
            ),
          ),
        );
        try {
          await httpClient.get(Uri.parse('test'));
          expect(false, true);
        } catch (e) {
          expect(e is UnreachableHttpError, isTrue,
              reason: 'e is UnreachableHttpError');
        }
      });
    });
  });
}
