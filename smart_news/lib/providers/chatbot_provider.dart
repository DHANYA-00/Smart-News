import 'package:flutter/material.dart';
import '../services/groq_service.dart';

class ChatbotProvider extends ChangeNotifier {
  ChatbotProvider(
    this._groqService, {
    this.articleContext,
    this.userLanguage = 'English',
  });

  final GroqService _groqService;

  /// If set, the chatbot is scoped to this article's content.
  /// If null, the chatbot acts as a global news assistant.
  final String? articleContext;
  String userLanguage;

  void updateLanguage(String newLanguage) {
    if (userLanguage != newLanguage) {
      userLanguage = newLanguage;
    }
  }

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, String>> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Whether we're in article-context mode or global mode.
  bool get isArticleMode =>
      articleContext != null && articleContext!.trim().isNotEmpty;

  Future<void> sendMessage(String userMessage) async {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) return;

    // Add user message
    _messages.add({'role': 'user', 'content': trimmed});
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Build conversation history (exclude the message we just added)
      final conversationHistory =
          _messages.sublist(0, _messages.length - 1).toList();

      final apiMessage = '$trimmed\n\n[SYSTEM INSTRUCTION: You MUST respond to this message entirely in $userLanguage.]';

      final response = await _groqService.generateChatbotResponse(
        apiMessage,
        conversationHistory: conversationHistory,
        articleContext: articleContext,
        userLanguage: userLanguage,
      );

      _messages.add({'role': 'assistant', 'content': response});
      _error = null;
    } catch (e) {
      final errorMessage = _friendlyError(e.toString());
      _error = errorMessage;
      _messages.add({
        'role': 'assistant',
        'content': errorMessage,
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Converts raw exception messages to user-friendly strings.
  String _friendlyError(String raw) {
    if (raw.contains('GROQ_API_KEY') || raw.contains('gsk_')) {
      return '⚠️ SmartBot is not configured yet. Please check your API key settings.';
    }
    if (raw.contains('busy') || raw.contains('rate')) {
      return '⚠️ SmartBot is handling too many requests right now. Please wait a moment and try again.';
    }
    if (raw.contains('timeout') || raw.contains('SocketException') ||
        raw.contains('connection')) {
      return '⚠️ Connection issue. Please check your internet and try again.';
    }
    if (raw.contains('401') || raw.contains('403')) {
      return '⚠️ Invalid API key. Please check your Groq API key configuration.';
    }
    return '⚠️ Something went wrong. Please try again in a moment.';
  }
}
