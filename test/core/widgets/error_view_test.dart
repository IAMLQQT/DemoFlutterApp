import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/error/failure.dart';
import 'package:test_app/core/widgets/error_view.dart';

Future<void> pump(WidgetTester tester, Failure failure, {VoidCallback? onRetry}) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: ErrorView(failure: failure, onRetry: onRetry))));

void main() {
  final cases = <Failure, (String, IconData, bool)>{
    const NetworkFailure(): ('Mất kết nối', Icons.wifi_off_rounded, true),
    const TimeoutFailure(): ('Kết nối chậm', Icons.hourglass_bottom_rounded, true),
    const UnauthorizedFailure(): ('Phiên làm việc không hợp lệ', Icons.lock_outline_rounded, false),
    const ForbiddenFailure(): ('Không có quyền truy cập', Icons.block_rounded, false),
    const NotFoundFailure(): ('Không tìm thấy', Icons.search_off_rounded, false),
    const TooManyRequestsFailure(): ('Thao tác quá nhanh', Icons.speed_rounded, true),
    const ServerFailure(): ('Máy chủ gặp sự cố', Icons.cloud_off_rounded, true),
    const InvalidDataFailure(): ('Dữ liệu không hợp lệ', Icons.report_gmailerrorred_rounded, true),
    const SecurityFailure(): ('Kết nối không an toàn', Icons.gpp_bad_outlined, true),
    const BadRequestFailure(): ('Yêu cầu không hợp lệ', Icons.error_outline_rounded, false),
    const UnexpectedFailure(): ('Đã có lỗi', Icons.error_outline_rounded, true),
  };

  for (final MapEntry(key: failure, value: (title, icon, retry)) in cases.entries) {
    testWidgets('${failure.runtimeType}: title, icon, message and retry=$retry', (tester) async {
      await pump(tester, failure, onRetry: () {});

      expect(find.text(title), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
      expect(find.text(failure.message), findsOneWidget);
      expect(find.text('Thử lại'), retry ? findsOneWidget : findsNothing);
    });
  }

  testWidgets('pressing "Thử lại" calls onRetry', (tester) async {
    var calls = 0;
    await pump(tester, const NetworkFailure(), onRetry: () => calls++);

    await tester.tap(find.text('Thử lại'));

    expect(calls, 1);
  });

  testWidgets('no retry button without a callback', (tester) async {
    await pump(tester, const NetworkFailure());

    expect(find.text('Thử lại'), findsNothing);
  });
}
