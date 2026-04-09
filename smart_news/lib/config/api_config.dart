import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolves API keys from .env file or compile-time environment variables.
class ApiConfig {
  ApiConfig._();

  static const String _newsFromEnv = String.fromEnvironment(
    'WORLD_NEWS_API_KEY',
    defaultValue: '',
  );

  static const String _groqFromEnv = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  static const String _openrouterFromEnv = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

  static String get newsApiKey {
    final envKey = dotenv.env['WORLD_NEWS_API_KEY'] ?? '';
    return _newsFromEnv.isNotEmpty ? _newsFromEnv : envKey;
  }

  static bool get hasNewsApiKey => newsApiKey.isNotEmpty;

  static String get groqApiKey {
    final envKey = dotenv.env['GROQ_API_KEY'] ?? '';
    return _groqFromEnv.isNotEmpty ? _groqFromEnv : envKey;
  }

  static bool get hasGroqApiKey => groqApiKey.isNotEmpty;

  // Groq API keys usually start with "gsk_".
  static bool get hasValidGroqApiKey =>
      hasGroqApiKey && groqApiKey.trim().startsWith('gsk_');

  static String get openrouterApiKey {
    final envKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    return _openrouterFromEnv.isNotEmpty ? _openrouterFromEnv : envKey;
  }

  static bool get hasOpenrouterApiKey => openrouterApiKey.isNotEmpty;

  // OpenRouter API keys are typically long tokens
  static bool get hasValidOpenrouterApiKey =>
      hasOpenrouterApiKey && openrouterApiKey.trim().isNotEmpty;
}


