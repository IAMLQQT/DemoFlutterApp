import 'package:flutter/material.dart';

import '../error/failure.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared error screen: icon, title and message depend on the [Failure] type.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.failure,
    this.onRetry,
    this.compact = false,
  });

  final Failure failure;

  /// Shown as "Thử lại" only when the failure is retryable.
  final VoidCallback? onRetry;

  /// Smaller layout for use inside a page section instead of a full screen.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String title) = switch (failure) {
      NetworkFailure() => (Icons.wifi_off_rounded, 'Mất kết nối'),
      TimeoutFailure() => (Icons.hourglass_bottom_rounded, 'Kết nối chậm'),
      UnauthorizedFailure() => (Icons.lock_outline_rounded, 'Phiên làm việc không hợp lệ'),
      ForbiddenFailure() => (Icons.block_rounded, 'Không có quyền truy cập'),
      NotFoundFailure() => (Icons.search_off_rounded, 'Không tìm thấy'),
      TooManyRequestsFailure() => (Icons.speed_rounded, 'Thao tác quá nhanh'),
      ServerFailure() => (Icons.cloud_off_rounded, 'Máy chủ gặp sự cố'),
      InvalidDataFailure() => (Icons.report_gmailerrorred_rounded, 'Dữ liệu không hợp lệ'),
      SecurityFailure() => (Icons.gpp_bad_outlined, 'Kết nối không an toàn'),
      BadRequestFailure() => (Icons.error_outline_rounded, 'Yêu cầu không hợp lệ'),
      CancelledFailure() || UnexpectedFailure() => (Icons.error_outline_rounded, 'Đã có lỗi'),
    };
    final bool showRetry = onRetry != null && failure.isRetryable;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 36 : 56, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.detailTitle, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(failure.message, style: AppTextStyles.body, textAlign: TextAlign.center),
            if (showRetry) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
