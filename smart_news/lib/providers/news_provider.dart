import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import '../services/groq_service.dart';

class NewsProvider extends ChangeNotifier {
  NewsProvider(this._newsService, {GroqService? groqService})
      : _groqService = groqService ?? GroqService();

  final NewsService _newsService;
  final GroqService _groqService;

  List<News> _articles = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String _selectedCategory = 'General';

  static const List<String> categories = [
    'General',
    'Sports',
    'Politics',
    'Technology',
    'Business',
    'Science',
    'Health',
    'Tamil Nadu',
  ];

  List<News> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  Future<void> fetchArticles(String category) async {
    _isLoading = true;
    _error = null;
    _selectedCategory = category;
    notifyListeners();

    try {
      if (category == 'Tamil Nadu') {
        _articles = await _fetchTamilNaduNews();
      } else {
        _articles = await _newsService.fetchForCategory(category);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Tamil Nadu-relevant news using Groq AI filtering
  Future<List<News>> _fetchTamilNaduNews() async {
    // Fetch general world news
    final allNews = await _newsService.fetchForCategory('Tamil Nadu');

    // Filter for Tamil Nadu relevance using Groq
    try {
      final articlesToFilter = allNews
          .map((article) => {
            'id': article.id,
            'title': article.title,
            'description': article.description,
          })
          .toList();

      final relevantIds =
          await _groqService.filterTamilNaduRelevantArticles(articlesToFilter);

      // Return only Tamil Nadu-relevant articles
      final indiaArticles = allNews
          .where((article) => relevantIds.contains(article.id))
          .toList();

      return indiaArticles;
    } catch (e) {
      // If filtering fails, return all articles with a warning
      // The user can try again
      throw Exception('Failed to filter Tamil Nadu news: $e');
    }
  }

  /// Pull-to-refresh: reload current category
  Future<void> refreshArticles() async {
    _isRefreshing = true;
    _error = null;
    notifyListeners();

    try {
      if (_selectedCategory == 'Tamil Nadu') {
        _articles = await _fetchTamilNaduNews();
      } else {
        _articles = await _newsService.fetchForCategory(_selectedCategory);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory != category) {
      fetchArticles(category);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
