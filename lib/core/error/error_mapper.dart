import 'dart:io';

import 'package:dio/dio.dart';

import '../network/api_response.dart';
import 'failure.dart';

/// Turns any exception thrown while talking to the API into a [Failure].
/// Every repository uses this, so the rules live in one place.
Failure mapToFailure(Object error, [StackTrace? stackTrace]) {
  return switch (error) {
    Failure() => error,
    ApiException() => _fromEnvelope(error, stackTrace),
    DioException() => _fromDio(error, stackTrace),
    FormatException() || TypeError() => InvalidDataFailure(cause: error, stackTrace: stackTrace),
    SocketException() => NetworkFailure(cause: error, stackTrace: stackTrace),
    _ => UnexpectedFailure(cause: error, stackTrace: stackTrace),
  };
}

Failure _fromEnvelope(ApiException e, StackTrace? st) {
  // The envelope message is written for end users, so it is shown when present
  return _byStatus(
    e.status,
    serverMessage: e.message,
    serverCode: e.code,
    cause: e,
    stackTrace: st,
  );
}

Failure _fromDio(DioException e, StackTrace? st) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return TimeoutFailure(cause: e, stackTrace: st);
    case DioExceptionType.connectionError:
      return NetworkFailure(cause: e, stackTrace: st);
    case DioExceptionType.badCertificate:
      return SecurityFailure(cause: e, stackTrace: st);
    case DioExceptionType.cancel:
      return CancelledFailure(cause: e, stackTrace: st);
    case DioExceptionType.badResponse:
      final Object? body = e.response?.data;
      final Map<String, dynamic>? json = body is Map<String, dynamic> ? body : null;
      // HTTP-level messages are technical English ("Missing token"), so they are logged, not shown
      return _byStatus(
        e.response?.statusCode,
        serverCode: json?['code'],
        traceId: json?['traceId'] as String?,
        cause: e,
        stackTrace: st,
      );
    case DioExceptionType.unknown:
      // Dio wraps decoding and socket errors here
      return switch (e.error) {
        SocketException() => NetworkFailure(cause: e, stackTrace: st),
        FormatException() || TypeError() => InvalidDataFailure(cause: e, stackTrace: st),
        _ => UnexpectedFailure(cause: e, stackTrace: st),
      };
  }
}

Failure _byStatus(
  int? status, {
  String? serverMessage,
  Object? serverCode,
  String? traceId,
  Object? cause,
  StackTrace? stackTrace,
}) {
  return switch (status) {
    400 || 422 => BadRequestFailure.details(
        serverMessage ?? const BadRequestFailure().message,
        statusCode: status,
        serverCode: serverCode,
        traceId: traceId,
        cause: cause,
        stackTrace: stackTrace,
      ),
    401 => UnauthorizedFailure(
        statusCode: status,
        serverCode: serverCode,
        traceId: traceId,
        cause: cause,
        stackTrace: stackTrace,
      ),
    403 => ForbiddenFailure(
        statusCode: status,
        serverCode: serverCode,
        traceId: traceId,
        cause: cause,
        stackTrace: stackTrace,
      ),
    404 => NotFoundFailure.details(
        serverMessage ?? const NotFoundFailure().message,
        statusCode: status,
        serverCode: serverCode,
        traceId: traceId,
        cause: cause,
        stackTrace: stackTrace,
      ),
    408 => TimeoutFailure(statusCode: status, cause: cause, stackTrace: stackTrace),
    429 => TooManyRequestsFailure(
        statusCode: status,
        serverCode: serverCode,
        traceId: traceId,
        cause: cause,
        stackTrace: stackTrace,
      ),
    _ => ServerFailure.details(
        serverMessage ?? const ServerFailure().message,
        statusCode: status,
        serverCode: serverCode,
        traceId: traceId,
        cause: cause,
        stackTrace: stackTrace,
      ),
  };
}
