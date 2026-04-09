import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Enum to distinguish chatbot modes.
enum ChatbotMode {
  /// Bot is scoped to a specific article the user is reading.
  articleContext,

  /// Bot is a general global news assistant.
  globalNews,
}

class GroqService {
  // Groq API endpoint
  static const String _baseUrl = 'https://api.groq.com/openai/v1';

  // Best Groq model for chat — fast and capable
  static const String _chatModel = 'llama-3.3-70b-versatile';

  // Model for summarization / quiz generation tasks
  static const String _taskModel = 'llama-3.3-70b-versatile';

  static const Duration _defaultTimeout = Duration(seconds: 30);

  String get apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  bool get hasApiKey => apiKey.isNotEmpty && apiKey.trim().startsWith('gsk_');

  // ─────────────────────────────────────────────────────────────────────────
  // CHATBOT
  // ─────────────────────────────────────────────────────────────────────────

  /// Generate a chatbot response using Groq API.
  ///
  /// [userMessage]           – latest user message
  /// [conversationHistory]   – previous turns as {role, content} maps
  /// [articleContext]        – if set, scopes the bot to this article
  /// [userLanguage]          – language for the response (default English)
  Future<String> generateChatbotResponse(
    String userMessage, {
    List<Map<String, String>> conversationHistory = const [],
    String? articleContext,
    String userLanguage = 'English',
  }) async {
    _assertApiKey();

    final mode = (articleContext != null && articleContext.trim().isNotEmpty)
        ? ChatbotMode.articleContext
        : ChatbotMode.globalNews;

    final systemPrompt = _buildSmartBotSystemPrompt(
      articleContext: articleContext,
      userLanguage: userLanguage,
      mode: mode,
    );

    // Keep last 10 turns (20 messages) for context
    final limitedHistory = conversationHistory.length > 20
        ? conversationHistory.sublist(conversationHistory.length - 20)
        : conversationHistory;

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...limitedHistory,
      {'role': 'user', 'content': userMessage},
    ];

    final responseText = await _post(
      model: _chatModel,
      messages: messages,
      maxTokens: 1024,
      temperature: 0.65,
    );

    return responseText.trim();
  }

  /// Builds a smart, contextual system prompt based on the mode.
  String _buildSmartBotSystemPrompt({
    String? articleContext,
    required String userLanguage,
    required ChatbotMode mode,
  }) {
    final now = DateTime.now();
    final dateStr =
        '${now.day}/${now.month}/${now.year}'; // e.g. 9/4/2026

    if (mode == ChatbotMode.articleContext && articleContext != null) {
      return '''You are SmartBot, an intelligent AI news assistant embedded in the SmartNews app.

TODAY'S DATE: $dateStr
RESPONSE LANGUAGE: $userLanguage

═══ YOUR ROLE ════
The user is currently reading a specific news article. Your PRIMARY PURPOSE is to help them deeply understand this article — answer their questions about it, explain background context, clarify terminology, identify related topics, and help them learn.

═══ ARTICLE THE USER IS READING ════
$articleContext

═══ BEHAVIOR RULES ════
1. ALWAYS prioritize the article content above when answering. The user's questions will mostly be about this article.
2. You MAY provide additional real-world context to enrich answers (e.g., if article mentions a politician, briefly explain who they are).
3. If the user asks something unrelated to news/current events, gently redirect: "I'm SmartBot – I focus on news and current events. For this article, try asking me about [relevant topic from article]."
4. Never fabricate facts. If you're unsure, say: "I don't have verified information on that right now."
5. Keep answers concise (under 200 words) unless the user asks for more detail.
6. Format your response clearly. Use bullet points or numbered lists when helpful.
7. Respond in $userLanguage.

═══ SUGGESTED FOLLOW-UP TOPICS ════
After answering, optionally suggest 1–2 follow-up questions the user might find interesting based on the article.''';
    }

    // Global news mode
    return '''You are SmartBot, an expert AI news assistant inside the SmartNews app — your users' personal, knowledgeable journalist.

TODAY'S DATE: $dateStr
RESPONSE LANGUAGE: $userLanguage

═══ YOUR ROLE ════
Help users stay informed about the world. Answer questions about current events, explain news stories, provide context on political/economic/scientific developments, and help students prepare for exams like UPSC, SSC, and state-level competitive tests.

═══ TOPIC SCOPE ════
You ONLY answer questions related to:
• Breaking news & current affairs
• Politics & governance (India and world)
• Business, economy & markets
• Sports news & results
• Science, technology & innovation
• Health, medicine & environment
• Education & exam preparation (current affairs for competitive exams)
• History & geopolitics (when contextually relevant to today's news)

═══ BEHAVIOR RULES ════
1. If user asks something completely unrelated (e.g., "write code", "tell a joke", "cook a recipe"), say: "I'm SmartBot, your news companion. I cover news and current events. Try asking me about a recent story or current affairs topic!"
2. Never fabricate facts. If unsure, say: "I don't have verified data on that right now — I'd recommend checking a reliable news source."
3. For exam prep questions, focus on factual, concise points ideal for revision.
4. Keep answers under 200 words unless the user asks "explain in detail" or similar.
5. Use bullet points or numbered lists to improve clarity when listing facts.
6. Be balanced, neutral, and professional — do not express political opinions.
7. Respond in $userLanguage.

═══ PERSONALITY ════
Professional and warm — like a knowledgeable friend who reads the news every day. Engage the user's curiosity. After answering, feel free to suggest a related topic or follow-up question to keep them learning.''';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUMMARIZATION
  // ─────────────────────────────────────────────────────────────────────────

  /// Generate a summary of the given text using Groq API.
  Future<String> generateSummary(String text, {int maxLength = 150}) async {
    _assertApiKey();

    final messages = [
      {
        'role': 'system',
        'content':
            'You are a professional news summarizer. Summarize news articles concisely and accurately.',
      },
      {
        'role': 'user',
        'content':
            'Summarize the following news article in approximately $maxLength words. Focus on the key facts and what matters most:\n\n$text',
      },
    ];

    return (await _post(
      model: _taskModel,
      messages: messages,
      maxTokens: 512,
      temperature: 0.4,
    ))
        .trim();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // QUIZ GENERATION
  // ─────────────────────────────────────────────────────────────────────────

  /// Generate quiz questions from a given text using Groq API.
  Future<List<Map<String, dynamic>>> generateQuiz(
    String text, {
    int numQuestions = 5,
  }) async {
    _assertApiKey();

    final prompt = '''Generate $numQuestions multiple-choice quiz questions based on the following news text.
Return the response as a JSON array ONLY — no markdown, no explanation outside JSON.

JSON format:
[
  {
    "question": "Question text here?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswer": 0,
    "explanation": "Why this answer is correct"
  }
]

Text:
$text''';

    final messages = [
      {
        'role': 'system',
        'content': 'You generate quiz questions. Return ONLY valid JSON.',
      },
      {
        'role': 'user',
        'content': prompt,
      },
    ];

    final raw = await _post(
      model: _taskModel,
      messages: messages,
      maxTokens: 2048,
      temperature: 0.5,
    );

    return _parseJsonList(raw);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAMIL NADU FILTER
  // ─────────────────────────────────────────────────────────────────────────

  /// Filter articles to find Tamil Nadu-relevant ones.
  /// Returns list of article IDs that are Tamil Nadu-relevant.
  Future<List<String>> filterTamilNaduRelevantArticles(
    List<Map<String, dynamic>> articles,
  ) async {
    _assertApiKey();

    if (articles.isEmpty) return [];

    final systemPrompt =
        '''You are a news filter. Given a list of articles, return ONLY those relevant to Tamil Nadu, India.
An article is Tamil Nadu-relevant if it mentions Tamil Nadu, its cities (e.g. Chennai, Madurai, Coimbatore), Tamil politics, leaders, economy, culture, or local sports/events.
Return ONLY valid JSON: {"relevant_ids": ["id1", "id2"]}
No explanation outside JSON.''';

    final articlesList = articles
        .map((article) => {
              'id': article['id'] ?? '',
              'title': article['title'] ?? '',
              'description': article['description'] ?? '',
            })
        .toList();

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      {
        'role': 'user',
        'content': 'Filter these articles:\n\n${jsonEncode(articlesList)}',
      },
    ];

    final raw = await _post(
      model: _taskModel,
      messages: messages,
      maxTokens: 512,
      temperature: 0,
    );

    try {
      final parsed = jsonDecode(_extractJson(raw)) as Map<String, dynamic>;
      return (parsed['relevant_ids'] as List?)?.cast<String>().toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CURRENT AFFAIRS QUIZ
  // ─────────────────────────────────────────────────────────────────────────

  /// Generate current affairs quiz from multiple article strings.
  Future<List<Map<String, dynamic>>> generateCurrentAffairsQuiz(
    List<String> articles,
  ) async {
    _assertApiKey();

    if (articles.isEmpty) {
      throw Exception('No articles provided for quiz generation');
    }

    final systemPrompt =
        '''You are a quiz creator for students preparing for competitive exams (UPSC, SSC, etc.).
Given news articles, create 5 multiple-choice questions about current affairs.

Rules:
- Questions must be factual, based ONLY on the given articles
- 4 options per question (only one correct)
- Questions under 20 words
- Medium difficulty (class 10–12 level)
- Return ONLY valid JSON

Format:
{
  "questions": [
    {
      "question": "...",
      "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
      "correct": "A",
      "explanation": "One sentence why this is correct."
    }
  ]
}''';

    final articlesText = articles.join('\n\n---\n\n');
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      {
        'role': 'user',
        'content':
            'Create a current affairs quiz from these articles:\n\n$articlesText',
      },
    ];

    final raw = await _post(
      model: _taskModel,
      messages: messages,
      maxTokens: 2048,
      temperature: 0.5,
    );

    try {
      final parsed =
          jsonDecode(_extractJson(raw)) as Map<String, dynamic>;
      return (parsed['questions'] as List?)
              ?.cast<Map<String, dynamic>>()
              .toList() ??
          [];
    } catch (e) {
      throw Exception('Failed to parse quiz JSON: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CORE HTTP HELPER
  // ─────────────────────────────────────────────────────────────────────────

  /// POST to Groq chat completions endpoint with retry logic.
  Future<String> _post({
    required String model,
    required List<Map<String, dynamic>> messages,
    required int maxTokens,
    required double temperature,
  }) async {
    _assertApiKey();

    final uri = Uri.parse('$_baseUrl/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': model,
      'messages': messages,
      'max_tokens': maxTokens,
      'temperature': temperature,
    });

    for (var attempt = 0; attempt < 3; attempt++) {
      late http.Response response;

      try {
        response = await http
            .post(uri, headers: headers, body: body)
            .timeout(_defaultTimeout);
      } catch (e) {
        if (attempt == 2) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 800 * (attempt + 1)));
        continue;
      }

      if (response.statusCode == 200) {
        return _extractContent(response.body);
      }

      final status = response.statusCode;

      if (status == 401 || status == 403) {
        throw Exception(
            'Invalid Groq API key. Please check your GROQ_API_KEY in the .env file.');
      }

      if (status == 429 || status >= 500) {
        // Rate limited or server error — wait and retry
        await Future<void>.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
        continue;
      }

      final errMsg = _extractApiError(response.body);
      throw Exception('Groq API error ($status): $errMsg');
    }

    throw Exception(
        'Groq is currently busy. Please wait a moment and try again.');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESPONSE PARSING HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  String _extractContent(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw Exception('Groq returned no content.');
      }
      final message = choices.first as Map<String, dynamic>;
      final content =
          (message['message'] as Map<String, dynamic>?)?['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        throw Exception('Groq returned empty content.');
      }
      return content;
    } catch (e) {
      throw Exception('Failed to parse Groq response: $e');
    }
  }

  List<Map<String, dynamic>> _parseJsonList(String raw) {
    try {
      final text = _extractJson(raw);
      final decoded = jsonDecode(text);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to parse JSON response: $e');
    }
  }

  /// Strip markdown code fences and extract the JSON portion.
  String _extractJson(String raw) {
    var text = raw.trim();

    // Remove markdown code blocks
    if (text.startsWith('```')) {
      text = text
          .replaceAll(RegExp(r'^```(?:json)?[\r\n]?'), '')
          .replaceAll(RegExp(r'```$'), '')
          .trim();
    }

    // Try to find JSON boundaries
    final startArr = text.indexOf('[');
    final startObj = text.indexOf('{');
    final endArr = text.lastIndexOf(']');
    final endObj = text.lastIndexOf('}');

    if (startArr >= 0 && endArr > startArr) {
      // Prefer array
      if (startObj < 0 || startArr <= startObj) {
        return text.substring(startArr, endArr + 1);
      }
    }
    if (startObj >= 0 && endObj > startObj) {
      return text.substring(startObj, endObj + 1);
    }

    return text;
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

  // ─────────────────────────────────────────────────────────────────────────
  // ARTICLE EXPANSION
  // ─────────────────────────────────────────────────────────────────────────

  /// Generates a massive 8-paragraph expanded article based on the short snippet.
  Future<String> expandNewsArticle({
    required String title,
    required String content,
    String language = 'English',
  }) async {
    _assertApiKey();

    if (title.isEmpty) {
      throw Exception('Article title cannot be empty for expansion');
    }

    final prompt = '''
Act as an expert journalist. Based on the following news title and short snippet, write a comprehensive, highly detailed, and engaging news article. 

RULES (STRICT AND NON-NEGOTIABLE):
1. You MUST generate AT LEAST 8 paragraphs of text. Do not generate fewer than 8 paragraphs.
2. Structure it like a professional news report (introduction, context, analysis, quotes/perspectives, timeline if relevant, and future outlook).
3. If the provided snippet is too small, logically extrapolate reasonable journalistic context, background information surrounding the topic, and general impact to meet the strict 8-paragraph minimum requirement.
4. Do NOT use markdown headings or bold text, just raw paragraph text separated by double newlines.
5. Write fluently in $language language.

Title: $title
Short Snippet: $content

Expanded Article:''';

    final uri = Uri.parse('$_baseUrl/chat/completions');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'User-Agent': 'SmartNews/1.0 (Flutter)',
            },
            body: jsonEncode({
              'model': _taskModel, // uses llama-3.3-70b-versatile
              'messages': [
                {'role': 'user', 'content': prompt}
              ],
              'temperature': 0.7, // Higher temp for better creative expansion
              'max_tokens': 3500, // Very high to allow 8 paragraphs
              'top_p': 0.9,
            }),
          )
          .timeout(const Duration(seconds: 45)); // Allowed 45s for huge generation

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final message = decoded['choices'][0]['message']['content'] as String;
        return message.trim();
      } else {
        throw Exception(
            'Failed to expand article: ${response.statusCode} - ${_extractApiError(response.body)}');
      }
    } catch (e) {
      throw Exception('Error expanding article: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // API KEY VALIDATION
  // ─────────────────────────────────────────────────────────────────────────

  void _assertApiKey() {
    if (apiKey.isEmpty) {
      throw Exception(
          'GROQ_API_KEY is not set. Add it to your .env file.');
    }
    if (!apiKey.trim().startsWith('gsk_')) {
      throw Exception(
          'GROQ_API_KEY appears invalid (should start with "gsk_"). '
          'Please check your .env file.');
    }
  }
}
