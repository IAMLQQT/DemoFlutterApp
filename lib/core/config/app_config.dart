/// Values injected at build time with `--dart-define-from-file=env/dev.json`.
/// Keys must match the names in env/dev.json exactly.
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'api_base_url_example');
  static const String appKey = String.fromEnvironment('API_KEY', defaultValue: 'app_key_example');
  static const String token = String.fromEnvironment('API_TOKEN', defaultValue: 'token_example');
  static const String language = String.fromEnvironment('API_LANGUAGE', defaultValue: 'vi');

  /// Why the app cannot talk to the API, or null when the config looks usable.
  /// Catches the classic mistake of running without `--dart-define-from-file`.
  static String? get configError {
    final Uri? uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'API_BASE_URL không hợp lệ: "$baseUrl"';
    }
    if (appKey.isEmpty || appKey.endsWith('_example')) return 'Thiếu API_KEY';
    if (token.isEmpty || token.endsWith('_example')) return 'Thiếu API_TOKEN';
    return null;
  }
}
