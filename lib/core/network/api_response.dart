class ApiException implements Exception {
  const ApiException({required this.message, this.status});
  final String message;
  final int? status;

  @override
  String toString() {
    return 'ApiException: $message (status: $status)';
  }
}

T unwrapEnvelope<T>(Object? body, T Function(Object? data) parse) {

  if(body is! Map<String, dynamic>) {
    throw const FormatException('Response body is not a valid JSON object');
  }
  if(body['code'] !=1) {
    throw ApiException(
      status: body['status'] as int?,
      message: body['message'] ?? 'Unknown error',
    );
  } 
  return parse(body['data']);
}