/// Thrown when the API answers HTTP 200 but its envelope reports an error.
class ApiException implements Exception {
  const ApiException({this.message, this.status, this.code});

  /// Message written by the backend (Vietnamese), if any.
  final String? message;
  final int? status;
  final Object? code;

  @override
  String toString() => 'ApiException(status: $status, code: $code): $message';
}

/// Unwraps `{ status, code, message, data }`. The API returns HTTP 200 even
/// for errors, so success is decided by `code == 1`, not by the HTTP status.
T unwrapEnvelope<T>(Object? body, T Function(Object? data) parse) {
  if (body is! Map<String, dynamic>) {
    throw const FormatException('Response body is not a JSON object');
  }
  if (body['code'] != 1) {
    final Object? message = body['message'];
    final Object? status = body['status'];
    throw ApiException(
      message: message is String && message.trim().isNotEmpty ? message : null,
      status: status is int ? status : int.tryParse('$status'),
      code: body['code'],
    );
  }
  return parse(body['data']);
}
