import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/news_model.dart';
import '../providers/language_provider.dart';
import '../services/bookmarks_service.dart';
import '../services/quiz_generation_service.dart';
import '../services/groq_service.dart';
import '../widgets/quiz_bottom_sheet.dart';
import '../services/quiz_cache.dart';
import 'chatbot_screen.dart';

class NewsDetailScreen extends StatefulWidget {
  const NewsDetailScreen({super.key, required this.news});

  final News news;

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final BookmarksService _bookmarksService = BookmarksService.instance;
  final QuizGenerationService _quizService = QuizGenerationService();
  final QuizCache _quizCache = QuizCache();

  bool _isBookmarked = false;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _quizCache.init();
    _initializeBookmarks();
  }

  @override
  void dispose() {
    _quizService.dispose();
    super.dispose();
  }

  Future<void> _initializeBookmarks() async {
    await _bookmarksService.init();
    if (mounted) {
      final isBookmarked =
          await _bookmarksService.isBookmarked(widget.news.id);
      setState(() {
        _isBookmarked = isBookmarked;
        _initializing = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final wasAdded = await _bookmarksService.toggleBookmark(widget.news);
    if (mounted) {
      setState(() => _isBookmarked = wasAdded);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasAdded ? 'Bookmarked!' : 'Removed from bookmarks'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openQuiz() {
    final userLanguage =
        context.read<LanguageProvider>().getLanguageName();
    showQuizBottomSheet(
      context: context,
      articleId: widget.news.id,
      articleTitle: widget.news.title,
      articleContent: '${widget.news.description}\n\n${widget.news.content}',
      language: userLanguage,
      quizGenerationService: _quizService,
      quizCache: _quizCache,
    );
  }

  void _openChatbot() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatbotScreen(articleContext: widget.news),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          // SmartBot scoped to this article
          IconButton(
            onPressed: _openChatbot,
            icon: const Icon(Icons.smart_toy_rounded),
            tooltip: 'Ask SmartBot about this article',
          ),
          // Bookmark toggle
          if (!_initializing)
            IconButton(
              onPressed: _toggleBookmark,
              icon: Icon(
                _isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_add_outlined,
              ),
              tooltip: _isBookmarked ? 'Remove bookmark' : 'Bookmark',
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Scrollable content ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero image
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: widget.news.imageUrl.isEmpty
                        ? Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: theme.colorScheme.outline,
                              size: 48,
                            ),
                          )
                        : Image.network(
                            widget.news.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                  ),

                  // Source chip
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(widget.news.sourceName),
                        avatar: Icon(
                          Icons.public,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      widget.news.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Article body
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _ArticleBody(news: widget.news),
                  ),
                  const SizedBox(height: 16),

                  // Removed Read full article CTA per AI expansion logic
                ],
              ),
            ),
          ),

          // ── Bottom action bar ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Take Quiz
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _openQuiz,
                      icon: const Icon(Icons.quiz_rounded, size: 18),
                      label: const Text('Take Quiz'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Ask SmartBot
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openChatbot,
                      icon: const Icon(Icons.smart_toy_rounded, size: 18),
                      label: const Text('Ask SmartBot'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Article body widget ───────────────────────────────────────────────────────
class _ArticleBody extends StatefulWidget {
  const _ArticleBody({required this.news});
  final News news;

  @override
  State<_ArticleBody> createState() => _ArticleBodyState();
}

class _ArticleBodyState extends State<_ArticleBody> {
  final _groqService = GroqService();
  bool _isLoading = true;
  String? _expandedText;
  String? _error;

  @override
  void initState() {
    super.initState();
    _expandArticle();
  }

  Future<void> _expandArticle() async {
    // Basic snippet logic (title + description + content)
    final snippet = '${widget.news.description}\n\n${widget.news.content}';
    final lang = context.read<LanguageProvider>().getLanguageName();
    
    try {
      final expanded = await _groqService.expandNewsArticle(
        title: widget.news.title, 
        content: snippet,
        language: lang,
      );
      
      if (mounted) {
        setState(() {
          _expandedText = expanded;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to generate comprehensive article. Displaying limited preview instead.\n\n$snippet';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      height: 1.7,
      color: theme.colorScheme.onSurface,
      fontSize: 16,
    );

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              'Journalist AI is writing the article...',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Text(_error!, style: bodyStyle);
    }

    return Text(
      _expandedText ?? '',
      style: bodyStyle,
    );
  }
}
