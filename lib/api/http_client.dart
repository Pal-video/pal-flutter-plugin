import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

abstract class BaseHttpClient {}

/// use this Http client for every request on the app to be authenticated
/// intercept request and add user token if present
/// if token is expired calls refresh token endpoint and save new token
class HttpClient extends http.BaseClient implements BaseHttpClient {
  final http.Client _client;
  final String _baseUrl;
  String? _token;

  factory HttpClient.create(final String url, final String token) =>
      HttpClient.internal(url, token);

  @visibleForTesting
  HttpClient.internal(final String url, final String token,
      {http.Client? httpClient, bool testMode = false})
      : _baseUrl = url,
        _client = httpClient ?? http.Client(),
        _token = token {
    if (!testMode) {
      assert(url.isNotEmpty);
      assert(token.isNotEmpty);
    }
  }

  @override
  Future<http.StreamedResponse> send(final http.BaseRequest request) async {
    request.headers['Authorization'] = 'Bearer $_token';
    // request.headers['Host'] = 'stagingback.pal.video';
    return _client.send(request);
  }

  Future<Response> _checkResponse(final Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      String? errorCode;
      throw UnreachableHttpError(
          'Http ${response.statusCode} error, network or bad gateway : ${response.request?.url}',
          code: errorCode);
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      debugPrint('... ==> 500 error ${response.body}');
      throw InternalHttpError(
          'Http 500 error, internal error ${response.toString()}');
    } else {
      throw UnknownHttpError('e');
    }
  }

  @override
  Future<Response> post(
    final url, {
    Map<String, String>? headers,
    final body,
    final Encoding? encoding,
  }) async {
    headers = _initHeader(headers);
    // debugPrint('... ==> POST ${Uri.parse('$_baseUrl$url')}');
    // debugPrint('... ==> body $body');
    final response = await super.post(
      Uri.parse('$_baseUrl$url'),
      headers: headers,
      body: body,
      encoding: encoding,
    );
    return _checkResponse(response);
  }

  @override
  Future<Response> delete(
    final Uri url, {
    final Map<String, String>? headers,
    final body,
    final Encoding? encoding,
  }) async {
    return _checkResponse(
      await super.delete(
        Uri.parse('$_baseUrl$url'),
        headers: headers,
      ),
    );
  }

  @override
  Future<Response> put(
    final url, {
    Map<String, String>? headers,
    final body,
    final Encoding? encoding,
  }) async {
    headers = _initHeader(headers);
    var res = await super.put(
      Uri.parse('$_baseUrl$url'),
      headers: headers,
      body: body,
      encoding: encoding,
    );
    return _checkResponse(res);
  }

  @override
  Future<Response> patch(
    final url, {
    Map<String, String>? headers,
    final body,
    final Encoding? encoding,
  }) async {
    headers = _initHeader(headers);
    return _checkResponse(
      await super.patch(
        Uri.parse(
          '$_baseUrl$url',
        ),
        headers: headers,
        body: body,
        encoding: encoding,
      ),
    );
  }

  Map<String, String> _initHeader(Map<String, String>? headers) {
    headers ??= {};
    headers.putIfAbsent(
        HttpHeaders.contentTypeHeader, () => 'application/json; charset=UTF-8');
    return headers;
  }

  @override
  Future<Response> get(final url, {final Map<String, String>? headers}) async {
    return _checkResponse(
      await super.get(
        Uri.parse('$_baseUrl$url'),
        headers: headers,
      ),
    );
  }
}

class InternalHttpError implements Exception {
  String message;
  InternalHttpError(this.message);

  @override
  String toString() {
    return 'Exception: $message';
  }
}

class UnreachableHttpError implements Exception {
  String message;
  String? code;
  UnreachableHttpError(this.message, {this.code});
  @override
  String toString() {
    return 'Exception: $message';
  }
}

class UnknownHttpError implements Exception {
  String message;
  UnknownHttpError(this.message);

  @override
  String toString() {
    return 'Exception: $message';
  }
}
