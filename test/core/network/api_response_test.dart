import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/network/api_response.dart';

import '../../helpers/service_fixtures.dart';

void main() {
  test('returns parsed data when code is 1', () {
    final int count = unwrapEnvelope(screenResponseJson(), (data) => (data as List<dynamic>).length);

    expect(count, 3);
  });

  test('throws ApiException with status and message when code is not 1', () {
    expect(
      () => unwrapEnvelope(notFoundResponseJson, (data) => data),
      throwsA(isA<ApiException>()
          .having((e) => e.status, 'status', 404)
          .having((e) => e.message, 'message', 'Không tìm thấy dữ liệu.')),
    );
  });

  test('throws FormatException when the body is not an object', () {
    expect(() => unwrapEnvelope('oops', (data) => data), throwsA(isA<FormatException>()));
  });

  test('falls back to a default message when message is missing', () {
    expect(
      () => unwrapEnvelope({'status': 500, 'code': -1}, (data) => data),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Unknown error')),
    );
  });
}
