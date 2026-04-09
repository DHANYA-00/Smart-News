import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SummarizationException implements Exception {
  SummarizationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Service for generating article summaries using Groq API
class SummarizationService {
  SummarizationService({http.Client? httpClient})
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

  /// Summarize article into 3 bullet points
  /// Returns a list of 3 strings, each representing one bullet point
  Future<List<String>> summarizeArticle({
    required String title,
    required String content,
    String language = 'English',
  }) async {
    if (!hasApiKey) {
      throw SummarizationException(
        'Missing Groq API key. Add GROQ_API_KEY to .env file',
      );
    }

    if (title.isEmpty || content.isEmpty) {
      throw SummarizationException('Article title and content cannot be empty');
    }

    final prompt = _buildSummarizationPrompt(title, content, language);

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
              'temperature': 0.3,
              'max_tokens': 300,
              'top_p': 0.9,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw SummarizationException('Request timeout'),
          );

      if (response.statusCode != 200) {
        throw SummarizationException(_formatError(response));
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = body['choices'] as List<dynamic>? ?? [];

      if (choices.isEmpty) {
        throw SummarizationException('No response from Groq API');
      }

      final content = choices[0]['message']['content'] as String? ?? '';
      if (content.isEmpty) {
        throw SummarizationException('Empty response from Groq API');
      }

      return _parseResponse(content);
    } catch (e) {
      if (e is SummarizationException) rethrow;
      throw SummarizationException('Error: $e');
    }
  }

  /// Build the summarization prompt
  String _buildSummarizationPrompt(
    String title,
    String content,
    String language,
  ) {
    return '''Summarize the following news article into exactly 3 bullet points.

RULES:
- Each bullet point must be ONE sentence (max 20 words).
- Cover: (1) What happened, (2) Who is involved, (3) What is the impact or outcome.
- Use simple, clear language. No jargon.
- Do NOT copy sentences from the article — rephrase everything.
- Do NOT add opinions, analysis, or extra commentary.
- Respond in $language language.
- Format: Return ONLY the 3 bullet points, each starting with "•" on a new line.

Article:
Title: $title
Content: $content

Summary:''';
  }

  /// Parse the response and extract 3 bullet points
  List<String> _parseResponse(String response) {
    // Split by newlines and filter for bullet points
    final lines = response.split('\n').map((line) => line.trim()).toList();
    final bullets = <String>[];

    for (final line in lines) {
      if (line.isEmpty) continue;

      // Extract text after bullet character
      String text = line;
      if (text.startsWith('•')) {
        text = text.substring(1).trim();
      } else if (text.startsWith('-')) {
        text = text.substring(1).trim();
      } else if (text.startsWith('*')) {
        text = text.substring(1).trim();
      } else if (RegExp(r'^[\d]+[\.\)]\s').hasMatch(text)) {
        // Handle numbered bullets like "1." or "1)"
        text = text.replaceFirst(RegExp(r'^[\d]+[\.\)]\s'), '').trim();
      }

      if (text.isNotEmpty && bullets.length < 3) {
        bullets.add(text);
      }
    }

    // If we didn't get exactly 3, try to split differently
    if (bullets.length < 3) {
      final parts = response.split(RegExp(r'[\n•\-\*]'));
      bullets.clear();
      for (final part in parts) {
        final text = part.trim();
        if (text.isNotEmpty && bullets.length < 3) {
          bullets.add(text);
        }
      }
    }

    // Ensure we return exactly 3
    while (bullets.length < 3) {
      bullets.add('Summary point unavailable');
    }

    return bullets.take(3).toList();
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
