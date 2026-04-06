import 'package:flutter/material.dart';

import '../models/news_model.dart';
import '../models/quiz_model.dart';
import '../services/ai_service.dart';
import '../services/auth_service.dart';
import '../services/news_service.dart';
import '../widgets/category_chips.dart';
import '../widgets/news_card.dart';
import 'bookmarks_screen.dart';
import 'news_detail_screen.dart';
import 'quiz_screen.dart';
import 'quiz_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categories = [
    'All',
    'Sports',
    'Tech',
    'Education',
    'Politics',
  ];

  final NewsService _newsService = NewsService();
  final AiService _aiService = AiService();

  String _selectedCategory = 'All';
  List<News> _articles = [];
  bool _loading = true;
  String? _errorMessage;

  bool _dailyQuizLoading = false;
  List<QuizItem>? _todayQuizCache;
  String? _todayQuizDateKey;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  @override
  void dispose() {
    _newsService.dispose();
    _aiService.dispose();
    super.dispose();
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> _loadNews() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final list = await _newsService.fetchForCategory(_selectedCategory);
      if (!mounted) return;
      setState(() {
        _articles = list;
        _loading = false;
      });
    } on NewsApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _articles = [];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not load news. Check your connection and try again.';
        _articles = [];
        _loading = false;
      });
    }
  }

  Future<void> _openDailyQuiz() async {
    if (_dailyQuizLoading) return;

    if (_articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No article available for daily quiz yet.')),
      );
      return;
    }

    final todayKey = _todayKey;
    if (_todayQuizCache != null && _todayQuizDateKey == todayKey) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => QuizScreen(
            questions: _todayQuizCache!,
            quizTitle: "Today's Quiz",
          ),
        ),
      );
      return;
    }

    setState(() => _dailyQuizLoading = true);
    try {
      final article = _articles.first;
      final quiz = await _aiService.generateQuiz(
        title: article.title,
        description: article.detailBody,
      );

      if (!mounted) return;
      setState(() {
        _todayQuizCache = quiz;
        _todayQuizDateKey = todayKey;
      });

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => QuizScreen(
            questions: quiz,
            quizTitle: "Today's Quiz",
          ),
        ),
      );
    } on AiServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily quiz generation failed. Please retry.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _dailyQuizLoading = false);
      }
    }
  }

  void _onCategorySelected(String category) {
    if (category == _selectedCategory) return;
    setState(() => _selectedCategory = category);
    _loadNews();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartNews'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const QuizHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: 'Quiz History',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BookmarksScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Bookmarks',
          ),
          IconButton(
            onPressed: () => AuthService.instance.signOut(),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          CategoryChips(
            categories: _categories,
            selected: _selectedCategory,
            onSelected: _onCategorySelected,
          ),
          const SizedBox(height: 8),
          _buildTodayQuizSection(theme),
          Expanded(
            child: _buildBody(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayQuizSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Quiz",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'AI-generated current affairs practice in seconds.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _dailyQuizLoading ? null : _openDailyQuiz,
              child: _dailyQuizLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadNews,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_articles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNews,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.35,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'No stories in this category right now. Pull down to refresh.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final news = _articles[index];
          return NewsCard(
            news: news,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => NewsDetailScreen(news: news),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

