import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef Responder = Future<ResponseBody> Function(RequestOptions options);

/// Dio whose network layer is replaced by [respond]; records the last request.
class StubAdapter implements HttpClientAdapter {
  StubAdapter(this.respond);

  final Responder respond;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) {
    lastRequest = options;
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

Dio stubDio(StubAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = adapter;

ResponseBody jsonBody(int status, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );

ResponseBody rawBody(int status, String body, {String contentType = 'text/html'}) =>
    ResponseBody.fromString(body, status, headers: {Headers.contentTypeHeader: [contentType]});
