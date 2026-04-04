import 'package:flutter/material.dart';

import '../models/news_model.dart';
import '../services/news_service.dart';
import '../widgets/category_chips.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';

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

  String _selectedCategory = 'All';
  List<News> _articles = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  @override
  void dispose() {
    _newsService.dispose();
    super.dispose();
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
          Expanded(
            child: _buildBody(theme),
          ),
        ],
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
