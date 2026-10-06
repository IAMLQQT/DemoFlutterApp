import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/error/error_mapper.dart';
import 'package:test_app/core/error/failure.dart';
import 'package:test_app/features/services/data/datasources/service_remote_data_source.dart';

import '../../helpers/stub_dio.dart';

/// Runs a real request through Dio + the remote data source and maps what it throws.
Future<Failure> failureFor(Responder respond) async {
  final dataSource = ServiceRemoteDataSource(stubDio(StubAdapter(respond)));
  try {
    await dataSource.fetchServiceCategories();
  } catch (error, stackTrace) {
    return mapToFailure(error, stackTrace);
  }
  fail('expected the request to throw');
}

Map<String, Object?> envelope(int status, Object code, [String? message]) =>
    {'status': status, 'code': code, 'message': ?message, 'data': null};

void main() {
  group('API envelope (HTTP 200, code != 1)', () {
    test('status 404 -> NotFoundFailure with the server message', () async {
      final f = await failureFor((_) async =>
          jsonBody(200, envelope(404, -400, 'Không tìm thấy dữ liệu.')));
      expect(f, isA<NotFoundFailure>());
      expect(f.message, 'Không tìm thấy dữ liệu.');
      expect(f.statusCode, 404);
      expect(f.serverCode, -400);
    });

    test('status 400 -> BadRequestFailure, not retryable', () async {
      final f = await failureFor((_) async => jsonBody(200, envelope(400, -2, 'Thiếu tham số group')));
      expect(f, isA<BadRequestFailure>());
      expect(f.message, 'Thiếu tham số group');
      expect(f.isRetryable, isFalse);
    });

    test('status 500 with message -> ServerFailure keeps the server message', () async {
      final f = await failureFor((_) async => jsonBody(200, envelope(500, -1, 'Hệ thống đang bảo trì')));
      expect(f, isA<ServerFailure>());
      expect(f.message, 'Hệ thống đang bảo trì');
    });

    test('missing message -> Vietnamese default, never English', () async {
      final f = await failureFor((_) async => jsonBody(200, envelope(500, -1)));
      expect(f, isA<ServerFailure>());
      expect(f.message, const ServerFailure().message);
    });

    test('status sent as a string is still understood', () async {
      final f = await failureFor((_) async => jsonBody(200, {'status': '404', 'code': -400}));
      expect(f, isA<NotFoundFailure>());
    });
  });

  group('HTTP status errors', () {
    Future<Failure> http(int status, [Object? body]) =>
        failureFor((_) async => jsonBody(status, body ?? {'message': 'x'}));

    test('401 -> UnauthorizedFailure with server code and traceId', () async {
      final f = await http(401, {'code': 'UNAUTHORIZED', 'message': 'Missing token', 'traceId': 't-401'});
      expect(f, isA<UnauthorizedFailure>());
      expect(f.serverCode, 'UNAUTHORIZED');
      expect(f.traceId, 't-401');
      expect(f.message, isNot(contains('Missing token'))); // technical text stays in logs
      expect(f.isRetryable, isFalse);
    });

    test('403 -> ForbiddenFailure', () async => expect(await http(403), isA<ForbiddenFailure>()));

    test('404 -> NotFoundFailure with traceId', () async {
      final f = await http(404, {'code': 'NOT_FOUND', 'message': 'Not found', 'traceId': 't-404'});
      expect(f, isA<NotFoundFailure>());
      expect(f.traceId, 't-404');
      expect(f.statusCode, 404);
    });

    test('408 -> TimeoutFailure', () async => expect(await http(408), isA<TimeoutFailure>()));
    test('422 -> BadRequestFailure', () async => expect(await http(422), isA<BadRequestFailure>()));
    test('429 -> TooManyRequestsFailure', () async => expect(await http(429), isA<TooManyRequestsFailure>()));
    test('500 -> ServerFailure', () async => expect(await http(500), isA<ServerFailure>()));

    test('502 with an HTML body -> ServerFailure', () async {
      final f = await failureFor((_) async => rawBody(502, '<html>Bad Gateway</html>'));
      expect(f, isA<ServerFailure>());
      expect(f.statusCode, 502);
    });
  });

  group('unreadable responses -> InvalidDataFailure', () {
    final cases = <String, Responder>{
      'HTML body with HTTP 200': (_) async => rawBody(200, '<html>maintenance</html>'),
      'broken JSON': (_) async => rawBody(200, '{"status":200,', contentType: Headers.jsonContentType),
      'empty body': (_) async => rawBody(200, '', contentType: Headers.jsonContentType),
      'data is null': (_) async => jsonBody(200, {'status': 200, 'code': 1, 'data': null}),
      'data is an object instead of a list': (_) async =>
          jsonBody(200, {'status': 200, 'code': 1, 'data': {'x': 1}}),
      'item without id': (_) async => jsonBody(200, {
            'status': 200,
            'code': 1,
            'data': [
              {'name': 'A', 'news': [{'type': 2, 'items': [{'title': 'no id'}]}]},
            ],
          }),
    };
    for (final entry in cases.entries) {
      test(entry.key, () async => expect(await failureFor(entry.value), isA<InvalidDataFailure>()));
    }
  });

  group('transport errors', () {
    test('connect timeout -> TimeoutFailure', () async {
      final f = await failureFor((o) async =>
          throw DioException.connectionTimeout(timeout: const Duration(seconds: 1), requestOptions: o));
      expect(f, isA<TimeoutFailure>());
    });

    test('receive timeout -> TimeoutFailure', () async {
      final f = await failureFor((o) async =>
          throw DioException.receiveTimeout(timeout: const Duration(seconds: 1), requestOptions: o));
      expect(f, isA<TimeoutFailure>());
    });

    test('no internet -> NetworkFailure', () async {
      final f = await failureFor((o) async => throw DioException.connectionError(
            requestOptions: o,
            reason: 'offline',
            error: const SocketException('Failed host lookup'),
          ));
      expect(f, isA<NetworkFailure>());
    });

    test('bad certificate -> SecurityFailure in Vietnamese', () async {
      final f = await failureFor((o) async => throw DioException.badCertificate(requestOptions: o));
      expect(f, isA<SecurityFailure>());
      expect(f.message, isNot(contains('certificate')));
    });

    test('cancelled -> CancelledFailure', () async {
      final f = await failureFor((o) async => throw DioException.requestCancelled(requestOptions: o, reason: 'x'));
      expect(f, isA<CancelledFailure>());
    });

    test('unknown error inside the adapter -> UnexpectedFailure keeps the cause', () async {
      final f = await failureFor((_) async => throw StateError('boom'));
      expect(f, isA<UnexpectedFailure>());
      expect(f.cause, isNotNull);
      expect(f.stackTrace, isNotNull);
    });
  });

  test('a Failure passes through unchanged', () {
    const failure = NetworkFailure();
    expect(mapToFailure(failure), same(failure));
  });

  test('debugDescription contains every technical detail', () async {
    final f = await failureFor((_) async =>
        jsonBody(404, {'code': 'NOT_FOUND', 'message': 'Not found', 'traceId': 't-1'}));
    expect(f.debugDescription, allOf(contains('NotFoundFailure'), contains('status=404'),
        contains('code=NOT_FOUND'), contains('traceId=t-1')));
  });
}
