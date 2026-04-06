import 'api_secrets.dart';

/// Resolves API keys from compile-time env values, falling back to local secrets.
class ApiConfig {
  ApiConfig._();

  static const String _newsFromEnv = String.fromEnvironment(
    'NEWS_API_KEY',
    defaultValue: '',
  );

  static const String _groqFromEnv = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  static String get newsApiKey =>
      _newsFromEnv.isNotEmpty ? _newsFromEnv : kNewsApiKey;

  static bool get hasNewsApiKey => newsApiKey.isNotEmpty;

  static String get groqApiKey =>
      _groqFromEnv.isNotEmpty ? _groqFromEnv : kGroqApiKey;

  static bool get hasGroqApiKey => groqApiKey.isNotEmpty;

  // Groq API keys usually start with "gsk_".
  static bool get hasValidGroqApiKey =>
      hasGroqApiKey && groqApiKey.trim().startsWith('gsk_');
}

