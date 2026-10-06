import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/app.dart';
import 'package:test_app/core/error/failure.dart';
import 'package:test_app/core/router/app_router.dart';
import 'package:test_app/core/widgets/error_view.dart';
import 'package:test_app/features/services/data/models/service_detail_model.dart';
import 'package:test_app/features/services/data/repositories/service_repository_impl.dart';
import 'package:test_app/features/services/presentation/bloc/service_list/service_list_bloc.dart';
import 'package:test_app/features/services/presentation/widgets/service_card.dart';

import '../../../../helpers/fake_service_data_source.dart';

/// Detail calls fail while [detailError] is set; list calls use [error].
class _FlakyDetailSource extends FakeServiceDataSource {
  Object? detailError;

  @override
  Future<ServiceDetailModel> fetchServiceDetail(String id) async {
    if (detailError != null) throw detailError!;
    return super.fetchServiceDetail(id);
  }
}

Future<void> pumpApp(WidgetTester tester, FakeServiceDataSource dataSource) async {
  // Network images cannot load in tests; ignore their errors
  final void Function(FlutterErrorDetails)? original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.library == 'image resource service') return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);

  appRouter.go(AppRoutes.services); // the router is global: reset between tests
  await tester.pumpWidget(App(serviceRepository: ServiceRepositoryImpl(dataSource)));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('list: cold-start failure shows ErrorView, retry loads data', (tester) async {
    final dataSource = FakeServiceDataSource(error: const NetworkFailure());
    await pumpApp(tester, dataSource);

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Mất kết nối'), findsOneWidget);

    dataSource.error = null;
    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(ErrorView), findsNothing);
    expect(find.byType(ServiceCard), findsNWidgets(2));
  });

  testWidgets('list: failed refresh keeps cards and shows a SnackBar', (tester) async {
    final dataSource = FakeServiceDataSource();
    await pumpApp(tester, dataSource);
    expect(find.byType(ServiceCard), findsNWidgets(2));

    dataSource.error = const ServerFailure();
    tester.element(find.byType(ServiceCard).first).read<ServiceListBloc>().add(const ServiceListRefreshed());
    await tester.pump();
    await tester.pump();

    expect(find.byType(ServiceCard), findsNWidgets(2));
    expect(find.widgetWithText(SnackBar, const ServerFailure().message), findsOneWidget);
  });

  testWidgets('detail: content failure keeps the header and retries in place', (tester) async {
    final dataSource = _FlakyDetailSource()..detailError = const TimeoutFailure();
    await pumpApp(tester, dataSource);

    await tester.tap(find.byType(ServiceCard).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Title a'), findsOneWidget); // header from the list
    expect(find.text('Kết nối chậm'), findsOneWidget);

    dataSource.detailError = null;
    await tester.ensureVisible(find.text('Thử lại'));
    await tester.pump(); // let the scroll settle before tapping
    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Detail a'), findsOneWidget);
    expect(find.byType(ErrorView), findsNothing);
  });

  testWidgets('detail: non-retryable failure has no retry button', (tester) async {
    final dataSource = _FlakyDetailSource()..detailError = const NotFoundFailure();
    await pumpApp(tester, dataSource);

    await tester.tap(find.byType(ServiceCard).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Không tìm thấy'), findsOneWidget);
    expect(find.text('Thử lại'), findsNothing);
  });

  testWidgets('unknown route shows the not-found page', (tester) async {
    await pumpApp(tester, FakeServiceDataSource());

    appRouter.go('/khong-ton-tai');
    await tester.pump();
    await tester.pump();

    expect(find.text('Không tìm thấy trang'), findsOneWidget);

    await tester.tap(find.text('Về trang dịch vụ'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(ServiceCard), findsNWidgets(2));
  });
}
