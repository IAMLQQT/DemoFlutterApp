/// Values injected at build time with `--dart-define-from-file=env/dev.json`.
/// Keys must match the names in env/dev.json exactly.
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'api_base_url_example');
  static const String appKey = String.fromEnvironment('API_KEY', defaultValue: 'app_key_example');
  static const String token = String.fromEnvironment('API_TOKEN', defaultValue: 'token_example');
  static const String language = String.fromEnvironment('API_LANGUAGE', defaultValue: 'vi');
}
