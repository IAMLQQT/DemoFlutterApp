/// Domain error shown to the user. [message] is always Vietnamese and safe to
/// display; the other fields are for logs and bug reports only.
sealed class Failure implements Exception {
  const Failure(
    this.message, {
    this.statusCode,
    this.serverCode,
    this.traceId,
    this.cause,
    this.stackTrace,
  });

  final String message;

  /// HTTP status, or the `status` field of the API envelope.
  final int? statusCode;

  /// `code` from the response body, e.g. -400 or "UNAUTHORIZED".
  final Object? serverCode;

  /// `traceId` from the response body; give it to the backend to find the request.
  final String? traceId;

  /// The original exception, kept for logging.
  final Object? cause;
  final StackTrace? stackTrace;

  /// Whether pressing "Thử lại" can reasonably succeed.
  bool get isRetryable => true;

  /// One line with every technical detail, for logs.
  String get debugDescription => [
        '$runtimeType: $message',
        if (statusCode != null) 'status=$statusCode',
        if (serverCode != null) 'code=$serverCode',
        if (traceId != null) 'traceId=$traceId',
        if (cause != null) 'cause=$cause',
      ].join(' | ');

  @override
  String toString() => message;
}

/// No connection, DNS failure.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.cause, super.stackTrace})
      : super('Không có kết nối mạng. Vui lòng kiểm tra Internet.');
}

/// Connect / send / receive timeout, HTTP 408.
final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.statusCode, super.cause, super.stackTrace})
      : super('Kết nối quá chậm. Vui lòng thử lại.');
}

/// HTTP 400 / 422 or an envelope rejecting the request.
final class BadRequestFailure extends Failure {
  const BadRequestFailure([
    super.message = 'Yêu cầu không hợp lệ.',
  ]) : super();

  const BadRequestFailure.details(
    super.message, {
    super.statusCode,
    super.serverCode,
    super.traceId,
    super.cause,
    super.stackTrace,
  });

  @override
  bool get isRetryable => false;
}

/// HTTP 401: missing, wrong or expired token.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.statusCode,
    super.serverCode,
    super.traceId,
    super.cause,
    super.stackTrace,
  }) : super('Phiên làm việc không hợp lệ hoặc đã hết hạn.');

  @override
  bool get isRetryable => false;
}

/// HTTP 403.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.statusCode,
    super.serverCode,
    super.traceId,
    super.cause,
    super.stackTrace,
  }) : super('Bạn không có quyền xem nội dung này.');

  @override
  bool get isRetryable => false;
}

/// HTTP 404 or envelope status 404.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Không tìm thấy dữ liệu.']) : super();

  const NotFoundFailure.details(
    super.message, {
    super.statusCode,
    super.serverCode,
    super.traceId,
    super.cause,
    super.stackTrace,
  });

  @override
  bool get isRetryable => false;
}

/// HTTP 429.
final class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure({
    super.statusCode,
    super.serverCode,
    super.traceId,
    super.cause,
    super.stackTrace,
  }) : super('Bạn thao tác quá nhanh. Vui lòng thử lại sau ít phút.');
}

/// HTTP 5xx, unknown HTTP status, or an envelope error from the server.
final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.',
  ]) : super();

  const ServerFailure.details(
    super.message, {
    super.statusCode,
    super.serverCode,
    super.traceId,
    super.cause,
    super.stackTrace,
  });
}

/// The response arrived but could not be read (HTML, broken JSON, wrong types).
final class InvalidDataFailure extends Failure {
  const InvalidDataFailure({super.statusCode, super.cause, super.stackTrace})
      : super('Dữ liệu trả về không hợp lệ. Vui lòng thử lại sau.');
}

/// TLS certificate rejected.
final class SecurityFailure extends Failure {
  const SecurityFailure({super.cause, super.stackTrace})
      : super('Kết nối không an toàn. Vui lòng kiểm tra mạng đang dùng.');
}

/// The request was cancelled on purpose; never shown to the user.
final class CancelledFailure extends Failure {
  const CancelledFailure({super.cause, super.stackTrace}) : super('Yêu cầu đã bị huỷ.');
}

/// Anything else.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.cause, super.stackTrace})
      : super('Đã có lỗi xảy ra. Vui lòng thử lại.');
}
