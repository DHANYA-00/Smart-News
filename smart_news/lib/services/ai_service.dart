import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/quiz_model.dart';

class AiServiceException implements Exception {
  AiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AiService {
  AiService({http.Client? httpClient})
      : _client = httpClient ?? http.Client(),
        _ownsClient = httpClient == null;

  final http.Client _client;
  final bool _ownsClient;

  static const _authority = 'api.groq.com';
  static const _path = '/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';
  static const _timeout = Duration(seconds: 25);

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Future<List<QuizItem>> generateQuiz({
    required String title,
    required String description,
    int minQuestions = 3,
    int maxQuestions = 5,
  }) async {
    if (kIsWeb) {
      throw AiServiceException(
        'AI quiz generation is disabled on Web builds to protect API keys. '
        'Run on Android/Windows/macOS instead.',
      );
    }
    if (!ApiConfig.hasGroqApiKey) {
      throw AiServiceException(
        'Missing Groq key. Use --dart-define=GROQ_API_KEY=your_key '
        'or set kGroqApiKey in lib/config/api_secrets.dart.',
      );
    }
    if (!ApiConfig.hasValidGroqApiKey) {
      throw AiServiceException(
        'Invalid Groq key format. It should start with "gsk_". '
        'Please update GROQ_API_KEY or kGroqApiKey.',
      );
    }

    final uri = Uri.https(_authority, _path);
    final prompt1 = _buildPrompt(title, description, minQuestions, maxQuestions);
    final raw1 = await _requestWithRetry(uri, prompt1);
    final parsed1 = _tryParseQuiz(raw1);
    if (parsed1 != null) return parsed1;

    // Retry once with a stricter prompt if the model wrapped JSON in text/markdown.
    final prompt2 = _buildStrictJsonPrompt(
      title,
      description,
      minQuestions,
      maxQuestions,
    );
    final raw2 = await _requestWithRetry(uri, prompt2);
    final parsed2 = _tryParseQuiz(raw2);
    if (parsed2 != null) return parsed2;

    throw AiServiceException(
      'AI returned an unexpected format. Please retry.',
    );
  }

  List<Map<String, dynamic>> _buildPrompt(
    String title,
    String description,
    int minQuestions,
    int maxQuestions,
  ) {
    return [
      {
        'role': 'system',
        'content':
            'You generate quizzes for students. Return ONLY valid JSON.',
      },
      {
        'role': 'user',
        'content':
            'Create $minQuestions to $maxQuestions multiple-choice questions from this article context. '
                'Each question must have exactly 4 options and one correct answer. '
                'Return ONLY a JSON array like: '
                '[{"question":"...","options":["A","B","C","D"],"answer":"A","explanation":"..."}]\n\n'
                'Title: $title\n'
                'Description: $description',
      },
    ];
  }

  List<Map<String, dynamic>> _buildStrictJsonPrompt(
    String title,
    String description,
    int minQuestions,
    int maxQuestions,
  ) {
    return [
      {
        'role': 'system',
        'content':
            'Return ONLY JSON. No markdown. No explanations outside JSON.',
      },
      {
        'role': 'user',
        'content':
            'Return a JSON array ONLY. No surrounding text.\n'
                'Create $minQuestions to $maxQuestions MCQs. Exactly 4 options each.\n'
                'Schema:\n'
                '[{"question": "...", "options": ["A","B","C","D"], "answer": "A", "explanation": "..." }]\n\n'
                'Title: $title\n'
                'Description: $description',
      },
    ];
  }

  Future<String> _requestWithRetry(
    Uri uri,
    List<Map<String, dynamic>> messages,
  ) async {
    final body = {
      'model': _model,
      'temperature': 0.2,
      'messages': messages,
    };

    // A few retries for transient failures (rate limit / gateway errors).
    for (var attempt = 0; attempt < 3; attempt++) {
      final response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer ${ApiConfig.groqApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return _extractAssistantContent(response.body);
      }

      final status = response.statusCode;
      final msg = _extractApiError(response.body);

      if (status == 401 || status == 403) {
        throw AiServiceException('Groq auth failed: $msg');
      }

      if (status == 429 || status >= 500) {
        final delayMs = 600 * (attempt + 1);
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        continue;
      }

      throw AiServiceException('Quiz generation failed ($status): $msg');
    }

    throw AiServiceException(
      'Groq is busy (rate limited). Please wait and try again.',
    );
  }

  String _extractAssistantContent(String responseBody) {
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw AiServiceException('AI returned no quiz content.');
    }
    final message = choices.first as Map<String, dynamic>;
    final content =
        (message['message'] as Map<String, dynamic>?)?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw AiServiceException('AI returned empty quiz content.');
    }
    return content;
  }

  List<QuizItem>? _tryParseQuiz(String raw) {
    try {
      final items = _parseQuizJson(raw);
      if (items.isEmpty) return null;
      return items;
    } catch (_) {
      return null;
    }
  }

  List<QuizItem> _parseQuizJson(String rawText) {
    var text = rawText.trim();

    if (text.startsWith('```')) {
      text = text.replaceAll(RegExp(r'^```(?:json)?'), '').replaceAll(RegExp(r'```$'), '').trim();
    }

    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start >= 0 && end > start) {
      text = text.substring(start, end + 1);
    }

    final decoded = jsonDecode(text);
    if (decoded is! List<dynamic>) {
      return [];
    }

    final list = <QuizItem>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      final quiz = QuizItem.fromJson(item);
      if (quiz.question.isEmpty) continue;
      list.add(quiz);
    }
    return list;
  }

  String _extractApiError(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final error = decoded['error'] as Map<String, dynamic>?;
      return error?['message'] as String? ?? 'Unknown API error';
    } catch (_) {
      return 'Unknown API error';
    }
  }
}

