import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/network/api_response.dart';
import 'package:test_app/features/services/data/datasources/service_remote_data_source.dart';

import '../../../../helpers/service_fixtures.dart';

/// Answers every request with a canned JSON body and records what was asked.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.body);

  final Map<String, dynamic> body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  Dio buildDio(_StubAdapter adapter) =>
      Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = adapter;

  test('fetchServiceCategories calls /news/screen?group=service', () async {
    final adapter = _StubAdapter(screenResponseJson());
    final dataSource = ServiceRemoteDataSource(buildDio(adapter));

    final categories = await dataSource.fetchServiceCategories();

    expect(adapter.lastRequest?.method, 'GET');
    expect(adapter.lastRequest?.path, '/news/screen');
    expect(adapter.lastRequest?.queryParameters, {'group': 'service'});
    expect(categories.map((c) => c.id), ['hot-id', 'skin-id', 'care-id']);
  });

  test('fetchServiceDetail calls /news/content/{id}', () async {
    final adapter = _StubAdapter(detailResponseJson('abc'));
    final dataSource = ServiceRemoteDataSource(buildDio(adapter));

    final detail = await dataSource.fetchServiceDetail('abc');

    expect(adapter.lastRequest?.path, '/news/content/abc');
    expect(detail.title, 'Detail abc');
  });

  test('throws ApiException when the envelope reports an error', () async {
    final dataSource = ServiceRemoteDataSource(buildDio(_StubAdapter(notFoundResponseJson)));

    expect(dataSource.fetchServiceDetail('missing'), throwsA(isA<ApiException>()));
  });
}
