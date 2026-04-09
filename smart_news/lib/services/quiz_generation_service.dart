import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizGenerationException implements Exception {
  QuizGenerationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String? ?? '',
      options: List<String>.from(json['options'] as List? ?? []),
      correctAnswer: json['answer'] as String? ?? 'A',
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'answer': correctAnswer,
  };
}

/// Service for generating article quizzes using Groq API
class QuizGenerationService {
  QuizGenerationService({http.Client? httpClient})
      : _client = httpClient ?? http.Client(),
        _ownsClient = httpClient == null;

  final http.Client _client;
  final bool _ownsClient;

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  static const _authority = 'api.groq.com';
  static const _userAgent = 'SmartNews/1.0 (Flutter; student app)';

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  bool get hasApiKey => _apiKey.isNotEmpty;

  /// Generate 3 quiz questions from article content
  Future<List<QuizQuestion>> generateQuiz({
    required String title,
    required String content,
    String language = 'English',
  }) async {
    if (!hasApiKey) {
      throw QuizGenerationException(
        'Missing Groq API key. Add GROQ_API_KEY to .env file',
      );
    }

    if (title.isEmpty || content.isEmpty) {
      throw QuizGenerationException('Article title and content cannot be empty');
    }

    final prompt = _buildQuizPrompt(title, content, language);

    try {
      final response = await _client
          .post(
            Uri.https(_authority, '/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'User-Agent': _userAgent,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'llama-3.3-70b-versatile',
              'messages': [
                {
                  'role': 'user',
                  'content': prompt,
                }
              ],
              'temperature': 0.5,
              'max_tokens': 800,
              'top_p': 0.9,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw QuizGenerationException('Request timeout'),
          );

      if (response.statusCode != 200) {
        throw QuizGenerationException(_formatError(response));
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = body['choices'] as List<dynamic>? ?? [];

      if (choices.isEmpty) {
        throw QuizGenerationException('No response from Groq API');
      }

      final responseContent = choices[0]['message']['content'] as String? ?? '';
      if (responseContent.isEmpty) {
        throw QuizGenerationException('Empty response from Groq API');
      }

      return _parseQuizResponse(responseContent);
    } catch (e) {
      if (e is QuizGenerationException) rethrow;
      throw QuizGenerationException('Error: $e');
    }
  }

  /// Build the quiz generation prompt
  String _buildQuizPrompt(
    String title,
    String content,
    String language,
  ) {
    return '''You are a news quiz generator. Read the article carefully and create a quiz to test understanding of the MOST IMPORTANT facts only.

RULES:
- Generate exactly 3 multiple-choice questions.
- Each question must test a KEY FACT (date, name, number, decision, outcome) — not general knowledge.
- Do NOT ask trivial or obvious questions.
- Each question must have 4 options: 1 correct answer, 3 plausible but wrong options.
- Mark the correct answer clearly with single letter (A, B, C, or D).
- Respond in $language language.
- Return ONLY valid JSON array format, nothing else.

Return ONLY a JSON array in this exact format:
[
  {
    "question": "...",
    "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
    "answer": "A"
  }
]

Article:
Title: $title
Content: $content

Quiz JSON:''';
  }

  /// Parse the response and extract quiz questions
  List<QuizQuestion> _parseQuizResponse(String response) {
    try {
      // Find JSON array in response
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']');

      if (jsonStart == -1 || jsonEnd == -1) {
        throw QuizGenerationException('Invalid JSON format in response');
      }

      final jsonStr = response.substring(jsonStart, jsonEnd + 1);
      final jsonList = jsonDecode(jsonStr) as List<dynamic>;

      final questions = <QuizQuestion>[];
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          try {
            final q = QuizQuestion.fromJson(item);
            if (q.question.isNotEmpty &&
                q.options.length == 4 &&
                q.correctAnswer.isNotEmpty) {
              questions.add(q);
            }
          } catch (_) {
            continue;
          }
        }
      }

      if (questions.length != 3) {
        throw QuizGenerationException(
            'Expected 3 questions, got ${questions.length}');
      }

      return questions;
    } catch (e) {
      throw QuizGenerationException('Failed to parse quiz: $e');
    }
  }

  String _formatError(http.Response response) {
    final code = response.statusCode;

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String?;
      if (message != null && message.isNotEmpty) {
        return 'Groq error ($code): $message';
      }
    } catch (_) {
      // ignore
    }

    switch (code) {
      case 400:
        return 'Groq error: Bad request';
      case 401:
        return 'Groq error: Invalid API key';
      case 403:
        return 'Groq error: Access forbidden';
      case 429:
        return 'Groq error: Rate limit exceeded - try again later';
      case 500:
        return 'Groq error: Server error';
      default:
        return 'Groq request failed ($code)';
    }
  }
}
