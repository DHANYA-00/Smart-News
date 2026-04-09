import 'package:flutter/material.dart';
import 'languages/en.dart';
import 'languages/hi.dart';
import 'languages/ta.dart';
import 'languages/te.dart';
import 'languages/kn.dart';
import 'languages/ml.dart';

class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('ta'),
    Locale('te'),
    Locale('kn'),
    Locale('ml'),
  ];

  static const List<String> supportedLanguageCodes = ['en', 'hi', 'ta', 'te', 'kn', 'ml'];
  static const List<String> supportedLanguageNames = ['English', 'हिन्दी', 'தமிழ்', 'తెలుగు', 'ಕನ್ನಡ', 'മലയാളം'];

  static late Map<String, String> _translations;

  static void setLocale(String languageCode) {
    switch (languageCode) {
      case 'hi':
        _translations = translationsHi;
        break;
      case 'ta':
        _translations = translationsTa;
        break;
      case 'te':
        _translations = translationsTe;
        break;
      case 'kn':
        _translations = translationsKn;
        break;
      case 'ml':
        _translations = translationsMl;
        break;
      case 'en':
      default:
        _translations = translationsEn;
    }
  }

  static String translate(String key) {
    return _translations[key] ?? _translations['app_name'] ?? key;
  }

  static String get(String key) => translate(key);
}
