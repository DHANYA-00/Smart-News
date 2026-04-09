import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ArticleExpansionCache {
  static const String _storageKey = 'article_expansions_v1';
  late final SharedPreferences _prefs;
  bool _isInit = false;

  Future<void> init() async {
    if (_isInit) return;
    _prefs = await SharedPreferences.getInstance();
    _isInit = true;
  }

  /// Get cached expanded article if available
  String? getExpandedArticle(String articleId) {
    if (!_isInit) return null;
    try {
      final jsonStr = _prefs.getString(_storageKey);
      if (jsonStr == null) return null;

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      return data[articleId] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Save expanded article 
  Future<void> setExpandedArticle(String articleId, String paragraphs) async {
    if (!_isInit) return;
    try {
      final jsonStr = _prefs.getString(_storageKey);
      final data = jsonStr != null 
          ? (jsonDecode(jsonStr) as Map<String, dynamic>) 
          : <String, dynamic>{};

      data[articleId] = paragraphs;

      // Keep cache size manageable (max 40 articles)
      if (data.length > 40) {
        final keysToRemove = data.keys.take(data.length - 40).toList();
        for (final k in keysToRemove) {
          data.remove(k);
        }
      }

      await _prefs.setString(_storageKey, jsonEncode(data));
    } catch (_) {
      // Ignore cache write errors
    }
  }
}
