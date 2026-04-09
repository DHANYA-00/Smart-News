import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Manages caching of article summaries in local storage
class SummaryCache {
  static const String _cacheKeyPrefix = 'summary_';
  late SharedPreferences _prefs;

  /// Initialize the cache
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get cached summary for article
  /// Returns null if not cached
  List<String>? getSummary(String articleId) {
    try {
      final key = _cacheKeyPrefix + articleId;
      final jsonStr = _prefs.getString(key);
      if (jsonStr == null) return null;

      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => item as String).toList();
    } catch (e) {
      return null;
    }
  }

  /// Cache a summary
  Future<void> setSummary(String articleId, List<String> summary) async {
    try {
      final key = _cacheKeyPrefix + articleId;
      await _prefs.setString(key, jsonEncode(summary));
    } catch (e) {
      // Silently fail - cache is optional
    }
  }

  /// Check if summary is cached
  bool hasSummary(String articleId) {
    return _prefs.containsKey(_cacheKeyPrefix + articleId);
  }

  /// Clear all cached summaries
  Future<void> clearAll() async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cacheKeyPrefix)) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear specific article summary
  Future<void> clearSummary(String articleId) async {
    try {
      final key = _cacheKeyPrefix + articleId;
      await _prefs.remove(key);
    } catch (e) {
      // Silently fail
    }
  }
}
