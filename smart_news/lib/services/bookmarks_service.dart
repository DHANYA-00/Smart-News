import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';

class BookmarksService {
  BookmarksService._();

  static final BookmarksService instance = BookmarksService._();

  static const String _bookmarksKey = 'smart_news_bookmarks';

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<void> _ensureInit() async {
    if (!_initialized) {
      await init();
    }
  }

  /// Get all bookmarked articles
  Future<List<News>> getBookmarks() async {
    await _ensureInit();
    final jsonList = _prefs.getStringList(_bookmarksKey) ?? [];
    return jsonList
        .map((json) => News.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  /// Check if an article is bookmarked
  Future<bool> isBookmarked(String articleId) async {
    await _ensureInit();
    final bookmarks = await getBookmarks();
    return bookmarks.any((article) => article.id == articleId);
  }

  /// Add or remove a bookmark (toggle)
  Future<bool> toggleBookmark(News article) async {
    await _ensureInit();
    final bookmarks = await getBookmarks();
    final index = bookmarks.indexWhere((a) => a.id == article.id);

    if (index >= 0) {
      // Remove bookmark
      bookmarks.removeAt(index);
    } else {
      // Add bookmark
      bookmarks.insert(0, article);
    }

    final jsonList = bookmarks
        .map((article) => jsonEncode(article.toJson()))
        .toList();
    await _prefs.setStringList(_bookmarksKey, jsonList);

    return index < 0; // Return true if we added, false if we removed
  }

  /// Remove a specific bookmark by article ID
  Future<void> removeBookmark(String articleId) async {
    await _ensureInit();
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((article) => article.id == articleId);

    final jsonList = bookmarks
        .map((article) => jsonEncode(article.toJson()))
        .toList();
    await _prefs.setStringList(_bookmarksKey, jsonList);
  }

  /// Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    await _ensureInit();
    await _prefs.remove(_bookmarksKey);
  }

  /// Get number of bookmarks
  Future<int> getBookmarkCount() async {
    final bookmarks = await getBookmarks();
    return bookmarks.length;
  }
}
