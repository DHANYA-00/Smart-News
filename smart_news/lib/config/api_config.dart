import 'api_secrets.dart';

/// Resolves the NewsAPI.org key from compile-time env or [kNewsApiKey].
class ApiConfig {
  ApiConfig._();

  static const String _fromEnv = String.fromEnvironment(
    'NEWS_API_KEY',
    defaultValue: '',
  );

  static String get newsApiKey =>
      _fromEnv.isNotEmpty ? _fromEnv : kNewsApiKey;

  static bool get hasNewsApiKey => newsApiKey.isNotEmpty;
}
