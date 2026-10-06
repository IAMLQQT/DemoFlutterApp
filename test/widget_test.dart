import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/app.dart';
import 'package:test_app/features/services/data/repositories/service_repository_impl.dart';
import 'package:test_app/features/services/presentation/widgets/booking_button.dart';
import 'package:test_app/features/services/presentation/widgets/service_card.dart';

import 'helpers/fake_service_data_source.dart';

void main() {
  testWidgets('list shows services and detail renders the article', (tester) async {
    // Network images cannot load in tests; ignore their errors
    final void Function(FlutterErrorDetails)? originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.library == 'image resource service') return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      App(serviceRepository: ServiceRepositoryImpl(FakeServiceDataSource())),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(ServiceCard), findsNWidgets(2));
    expect(find.text('Dịch vụ HOT'), findsOneWidget);

    await tester.tap(find.byType(ServiceCard).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Detail a'), findsOneWidget);
    expect(find.textContaining('Noi dung a', findRichText: true, skipOffstage: false), findsOneWidget);
    // Booking button is shown because the API returned an active action
    expect(find.byType(BookingButton), findsOneWidget);
    // Label must come from the API's button_title
    expect(find.text('ĐẶT LỊCH NGAY'), findsOneWidget);
  });
}
