import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'quiz_generation_service.dart';

/// Manages caching of article quizzes and tracking quiz scores
class QuizCache {
  static const String _quizCacheKeyPrefix = 'quiz_';
  static const String _scoreKeyPrefix = 'quiz_score_';
  static const String _streakKey = 'quiz_streak';
  static const String _totalScoreKey = 'quiz_total_score';
  
  late SharedPreferences _prefs;

  /// Initialize the cache
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get cached quiz for article
  Future<List<QuizQuestion>?> getQuiz(String articleId) async {
    try {
      final key = _quizCacheKeyPrefix + articleId;
      final jsonStr = _prefs.getString(key);
      if (jsonStr == null) return null;

      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Cache a quiz
  Future<void> setQuiz(String articleId, List<QuizQuestion> quiz) async {
    try {
      final key = _quizCacheKeyPrefix + articleId;
      final jsonList = quiz.map((q) => q.toJson()).toList();
      await _prefs.setString(key, jsonEncode(jsonList));
    } catch (e) {
      // Silently fail
    }
  }

  /// Check if quiz is cached
  bool hasQuiz(String articleId) {
    return _prefs.containsKey(_quizCacheKeyPrefix + articleId);
  }

  /// Record quiz completion score
  Future<void> recordScore(String articleId, int score, int totalQuestions) async {
    try {
      final key = _scoreKeyPrefix + articleId;
      await _prefs.setString(key, jsonEncode({
        'score': score,
        'total': totalQuestions,
        'timestamp': DateTime.now().toIso8601String(),
      }));

      // Update total score
      final currentTotal = _prefs.getInt(_totalScoreKey) ?? 0;
      await _prefs.setInt(_totalScoreKey, currentTotal + score);

      // Update streak
      _updateStreak();
    } catch (e) {
      // Silently fail
    }
  }

  /// Get quiz score for article (if taken)
  Map<String, dynamic>? getScore(String articleId) {
    try {
      final key = _scoreKeyPrefix + articleId;
      final jsonStr = _prefs.getString(key);
      if (jsonStr == null) return null;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Get current streak (consecutive days of quiz completion)
  int getStreak() {
    return _prefs.getInt(_streakKey) ?? 0;
  }

  /// Get total score across all quizzes
  int getTotalScore() {
    return _prefs.getInt(_totalScoreKey) ?? 0;
  }

  /// Update streak tracking
  Future<void> _updateStreak() async {
    try {
      final now = DateTime.now();
      final lastQuizKey = 'quiz_last_date';
      final lastDateStr = _prefs.getString(lastQuizKey);

      if (lastDateStr == null) {
        // First quiz ever
        await _prefs.setInt(_streakKey, 1);
        await _prefs.setString(lastQuizKey, now.toIso8601String());
      } else {
        final lastDate = DateTime.parse(lastDateStr);
        final difference = now.difference(lastDate).inDays;

        if (difference == 0) {
          // Same day, no streak update
          return;
        } else if (difference == 1) {
          // Consecutive day, increase streak
          final currentStreak = _prefs.getInt(_streakKey) ?? 0;
          await _prefs.setInt(_streakKey, currentStreak + 1);
          await _prefs.setString(lastQuizKey, now.toIso8601String());
        } else {
          // Streak broken, reset
          await _prefs.setInt(_streakKey, 1);
          await _prefs.setString(lastQuizKey, now.toIso8601String());
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear all cached quizzes
  Future<void> clearAll() async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_quizCacheKeyPrefix)) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear specific article quiz
  Future<void> clearQuiz(String articleId) async {
    try {
      final key = _quizCacheKeyPrefix + articleId;
      await _prefs.remove(key);
    } catch (e) {
      // Silently fail
    }
  }
}
