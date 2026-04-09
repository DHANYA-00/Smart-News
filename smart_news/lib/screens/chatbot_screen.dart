import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import '../providers/chatbot_provider.dart';
import '../providers/language_provider.dart';
import '../services/groq_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key, this.articleContext});

  /// If provided, the bot is scoped to this specific article.
  /// If null, the bot operates as a global news assistant (bottom-nav tab mode).
  final News? articleContext;

  String? _buildArticleContextText(News article) {
    final buffer = StringBuffer()
      ..writeln('Title: ${article.title}')
      ..writeln('Source: ${article.sourceName}');
    if (article.publishedAt != null) {
      final d = article.publishedAt!;
      buffer.writeln('Published: ${d.day}/${d.month}/${d.year}');
    }
    if (article.description.trim().isNotEmpty) {
      buffer.writeln('\nDescription: ${article.description.trim()}');
    }
    if (article.content.trim().isNotEmpty) {
      buffer.writeln('\nContent: ${article.content.trim()}');
    }
    if (article.url.trim().isNotEmpty) {
      buffer.writeln('\nURL: ${article.url.trim()}');
    }
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final isArticleMode = articleContext != null;
    final articleContextText =
        isArticleMode ? _buildArticleContextText(articleContext!) : null;

    // Language is read from LanguageProvider so SmartBot mirrors the user's choice.
    final userLanguage =
        context.watch<LanguageProvider>().getLanguageName();

    // Article Mode → fresh scoped provider per article.
    // Global Mode  → reuse the global ChatbotProvider from main.dart.
    if (isArticleMode) {
      return ChangeNotifierProvider(
        create: (_) => ChatbotProvider(
          GroqService(),
          articleContext: articleContextText,
          userLanguage: userLanguage,
        ),
        child: _ChatbotBody(
          isArticleMode: true,
          article: articleContext,
        ),
      );
    }

    return _ChatbotBody(
      isArticleMode: false,
      article: null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChatbotBody — shared UI for both modes, reads from whichever
// ChatbotProvider is in the widget tree (global or scoped).
// ─────────────────────────────────────────────────────────────────────────────

class _ChatbotBody extends StatefulWidget {
  const _ChatbotBody({required this.isArticleMode, required this.article});

  final bool isArticleMode;
  final News? article;

  @override
  State<_ChatbotBody> createState() => _ChatbotBodyState();
}

class _ChatbotBodyState extends State<_ChatbotBody> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> get _suggestedQuestions {
    if (widget.isArticleMode) {
      return [
        'Summarize this article',
        'What is the key takeaway?',
        'Give me background context',
        'Who is involved in this story?',
      ];
    }
    return [
      "What's happening in India today?",
      'Latest sports news',
      'Top tech stories this week',
      'Economy update',
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    _messageController.clear();
    await context.read<ChatbotProvider>().sendMessage(message);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<ChatbotProvider>(
        builder: (context, provider, _) {
          final messages = provider.messages;
          final isLoading = provider.isLoading;

          return Column(
            children: [
              // Banner showing article title when in article mode
              if (widget.isArticleMode && widget.article != null)
                _buildArticleBanner(context),

              // Message list or welcome screen
              Expanded(
                child: messages.isEmpty
                    ? _buildWelcomeScreen(context)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ChatBubble(
                              message: msg['content'] ?? '',
                              isUserMessage: msg['role'] == 'user',
                            ),
                          );
                        },
                      ),
              ),

              // Typing indicator
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TypingIndicator(),
                  ),
                ),

              // Suggested question chips (only on empty chat)
              if (messages.isEmpty && !isLoading)
                _buildSuggestedChips(context),

              // Input bar
              _buildInputBar(context, isLoading),
            ],
          );
        },
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 20,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SmartBot',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Text(
                widget.isArticleMode
                    ? 'Article Assistant'
                    : 'Global News Assistant',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      actions: [
        Consumer<ChatbotProvider>(
          builder: (context, provider, _) => PopupMenuButton<String>(
            onSelected: (choice) {
              if (choice == 'clear') _showClearConfirmation(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: 'clear',
                enabled: provider.messages.isNotEmpty,
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Article banner ────────────────────────────────────────────────────────

  Widget _buildArticleBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.article_outlined,
              size: 16,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '📰 ${widget.article!.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Context loaded',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Welcome screen ────────────────────────────────────────────────────────

  Widget _buildWelcomeScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Hi! I'm SmartBot",
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                widget.isArticleMode
                    ? "I've read the article above — ask me anything about it!"
                    : "Your personal AI news companion. Ask me about current events, sports, tech, or exam prep!",
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: widget.isArticleMode
                    ? [
                        _featureItem(context,
                            icon: Icons.quiz_outlined,
                            title: 'Article Q&A',
                            desc: 'Ask any question about this article'),
                        const SizedBox(height: 14),
                        _featureItem(context,
                            icon: Icons.psychology_outlined,
                            title: 'Background Context',
                            desc: 'Get deeper context and explanations'),
                        const SizedBox(height: 14),
                        _featureItem(context,
                            icon: Icons.summarize_outlined,
                            title: 'Quick Summaries',
                            desc: 'Get a concise summary of key points'),
                      ]
                    : [
                        _featureItem(context,
                            icon: Icons.newspaper_outlined,
                            title: 'Current Events',
                            desc: 'Latest news from India and the world'),
                        const SizedBox(height: 14),
                        _featureItem(context,
                            icon: Icons.school_outlined,
                            title: 'Exam Preparation',
                            desc:
                                'UPSC, SSC & competitive exam current affairs'),
                        const SizedBox(height: 14),
                        _featureItem(context,
                            icon: Icons.lightbulb_outlined,
                            title: 'Explain It Simply',
                            desc: 'Complex topics made easy to understand'),
                      ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc,
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Suggested chips ───────────────────────────────────────────────────────

  Widget _buildSuggestedChips(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _suggestedQuestions
            .map((q) => ActionChip(
                  label: Text(q,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  avatar: Icon(Icons.auto_awesome,
                      size: 14, color: theme.colorScheme.primary),
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                  side: BorderSide(
                      color:
                          theme.colorScheme.primary.withValues(alpha: 0.2)),
                  labelStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600),
                  onPressed: () {
                    _messageController.text = q;
                    _sendMessage(q);
                  },
                ))
            .toList(),
      ),
    );
  }

  // ── Input bar ─────────────────────────────────────────────────────────────

  Widget _buildInputBar(BuildContext context, bool isLoading) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !isLoading,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                decoration: InputDecoration(
                  hintText: widget.isArticleMode
                      ? 'Ask about this article...'
                      : 'Ask anything about news...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                        width: 0.8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                        color: theme.colorScheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              heroTag: 'smartbot_send',
              onPressed:
                  isLoading ? null : () => _sendMessage(_messageController.text),
              elevation: isLoading ? 0 : 2,
              backgroundColor: isLoading
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primary,
              child: Icon(
                isLoading
                    ? Icons.hourglass_top_rounded
                    : Icons.send_rounded,
                size: 18,
                color: isLoading
                    ? theme.colorScheme.onSurfaceVariant
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Clear chat dialog ─────────────────────────────────────────────────────

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Chat?'),
        content:
            const Text('This will delete all messages in this conversation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatbotProvider>().clearChat();
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
