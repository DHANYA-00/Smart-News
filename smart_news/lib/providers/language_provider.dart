import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  Locale _currentLocale = const Locale('en');
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  bool get isInitialized => _isInitialized;

  /// Initialize the provider and load saved language preference
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedLanguage = _prefs.getString(_languageKey) ?? 'en';
      _currentLocale = Locale(savedLanguage);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing LanguageProvider: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Change the app language
  Future<void> setLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) {
      return; // Already set to this language
    }

    try {
      _currentLocale = Locale(languageCode);
      await _prefs.setString(_languageKey, languageCode);
      notifyListeners();
      debugPrint('Language changed to: $languageCode');
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  /// Get the current language name for display
  String getLanguageName() {
    switch (_currentLocale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'ta':
        return 'தமிழ்';
      case 'te':
        return 'తెలుగు';
      case 'kn':
        return 'ಕನ್ನಡ';
      case 'ml':
        return 'മലയാളം';
      default:
        return 'English';
    }
  }

  /// Get all supported language codes
  static List<String> getSupportedLanguageCodes() {
    return ['en', 'hi', 'ta', 'te', 'kn', 'ml'];
  }

  /// Get all supported language names
  static Map<String, String> getSupportedLanguages() {
    return {
      'en': 'English',
      'hi': 'हिंदी',
      'ta': 'தமிழ்',
      'te': 'తెలుగు',
      'kn': 'ಕನ್ನಡ',
      'ml': 'മലയാളം',
    };
  }
}
