import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/config/app_config.dart';

void main() {
  test('reports a config error when run without the env file', () {
    // `flutter test` runs without --dart-define-from-file, so defaults are used
    expect(ApiConfig.configError, contains('API_BASE_URL'));
  });
}
