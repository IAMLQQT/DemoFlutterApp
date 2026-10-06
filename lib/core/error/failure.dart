sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Không có kết nối mạng']);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Bạn không có quyền truy cập']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Không tìm thấy dữ liệu']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Máy chủ đang gặp sự cố']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Đã có lỗi xảy ra']);
}
