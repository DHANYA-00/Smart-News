import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/language_provider.dart';
import '../services/quiz_generation_service.dart';
import '../services/quiz_cache.dart';
import '../widgets/enhanced_news_card.dart';
import '../services/summarization_service.dart';
import '../services/summary_cache.dart';
import '../widgets/news_card_skeleton.dart';
import '../widgets/empty_state.dart';
import '../widgets/category_filter_bar.dart';
import 'news_detail_screen.dart';

class NewsFeeds extends StatefulWidget {
  const NewsFeeds({super.key});

  @override
  State<NewsFeeds> createState() => _NewsFeedsState();
}

class _NewsFeedsState extends State<NewsFeeds> {
  late ScrollController _scrollController;
  late QuizGenerationService _quizGenerationService;
  late QuizCache _quizCache;
  late SummarizationService _summarizationService;
  late SummaryCache _summaryCache;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _quizGenerationService = QuizGenerationService();
    _quizCache = QuizCache();
    _quizCache.init();
    _summarizationService = SummarizationService();
    _summaryCache = SummaryCache();
    _summaryCache.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = context.read<NewsProvider>();
      if (newsProvider.articles.isEmpty) {
        newsProvider.fetchArticles('General');
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _quizGenerationService.dispose();
    _summarizationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamil Nadu & World News'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Consumer<NewsProvider>(
            builder: (context, newsProvider, _) => CategoryFilterBar(
              categories: NewsProvider.categories,
              selectedCategory: newsProvider.selectedCategory,
              onCategorySelected: newsProvider.selectCategory,
            ),
          ),
        ),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, _) {
          // Error
          if (newsProvider.error != null && newsProvider.articles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 56, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text('Failed to load news',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      newsProvider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          newsProvider.fetchArticles(newsProvider.selectedCategory),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Loading
          if (newsProvider.isLoading && newsProvider.articles.isEmpty) {
            return const NewsListSkeleton();
          }

          // Empty
          if (newsProvider.articles.isEmpty) {
            return EmptyState(
              icon: Icons.newspaper,
              title: 'No news available',
              subtitle: 'Pull down to refresh or try another category',
            );
          }

          final userLanguage =
              context.watch<LanguageProvider>().getLanguageName();

          return RefreshIndicator(
            onRefresh: () => newsProvider.refreshArticles(),
            color: Theme.of(context).colorScheme.primary,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: newsProvider.articles.length,
              itemBuilder: (context, index) {
                final article = newsProvider.articles[index];
                return EnhancedNewsCard(
                  article: article,
                  currentCategory: newsProvider.selectedCategory,
                  quizGenerationService: _quizGenerationService,
                  quizCache: _quizCache,
                  summarizationService: _summarizationService,
                  summaryCache: _summaryCache,
                  userLanguage: userLanguage,
                  onReadMore: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => NewsDetailScreen(news: article),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
