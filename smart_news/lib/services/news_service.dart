import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/news_model.dart';

class NewsApiException implements Exception {
  NewsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Fetches news from [NewsAPI.org](https://newsapi.org/).
/// Free tier: 100 requests/day with category support.
class NewsService {
  NewsService({http.Client? httpClient})
      : _client = httpClient ?? http.Client(),
        _ownsClient = httpClient == null;

  final http.Client _client;
  final bool _ownsClient;

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  static const _authority = 'newsapi.org';
  static const _userAgent = 'SmartNews/1.0 (Flutter; student app)';

  // Category mapping for NewsAPI
  static const Map<String, String> _categoryMap = {
    'General': 'general',
    'Sports': 'sports',
    'Politics': 'general', // NewsAPI doesn't have politics, use general
    'Technology': 'technology',
    'Business': 'business',
    'Science': 'science',
    'Health': 'health',
    'Entertainment': 'entertainment',
  };

  String get _apiKey => dotenv.env['NEWSAPI_API_KEY'] ?? '';

  bool get hasApiKey => _apiKey.isNotEmpty;

  /// Maps UI chip labels to API behavior.
  Future<List<News>> fetchForCategory(String categoryLabel) async {
    if (!hasApiKey) {
      throw NewsApiException(
        'Missing NewsAPI key. Add NEWSAPI_API_KEY to .env file. '
        'Get free key at https://newsapi.org/',
      );
    }

    switch (categoryLabel) {
      case 'Tamil Nadu':
        return _fetchTamilNaduNews();
      default:
        return _fetchCategoryNews(categoryLabel);
    }
  }

  /// Fetch Tamil Nadu-specific top headlines (using India as base)
  Future<List<News>> _fetchTamilNaduNews() async {
    final queryParams = {
      'apiKey': _apiKey,
      'country': 'in',
      'pageSize': '50',
      'language': 'en',
    };

    final uri =
        Uri.https(_authority, '/v2/top-headlines', queryParams);
    return _fetchNews(uri, 'Tamil Nadu');
  }

  /// Fetch news by category
  Future<List<News>> _fetchCategoryNews(String categoryLabel) async {
    final category = _categoryMap[categoryLabel] ?? 'general';

    final queryParams = {
      'apiKey': _apiKey,
      'category': category,
      'pageSize': '50',
      'language': 'en',
    };
    
    if (categoryLabel == 'Politics') {
      queryParams['q'] = 'politics';
    }

    final uri =
        Uri.https(_authority, '/v2/top-headlines', queryParams);
    return _fetchNews(uri, categoryLabel);
  }

  Future<List<News>> _fetchNews(Uri uri, String category) async {
    try {
      final response = await _client
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw NewsApiException('Request timeout'),
          );

      if (response.statusCode != 200) {
        throw NewsApiException(_formatError(response));
      }

      final body = _decodeJson(response.body);

      // Parse articles
      final articles = body['articles'] as List<dynamic>? ?? [];
      final news = <News>[];

      for (final item in articles) {
        if (item is! Map<String, dynamic>) continue;

        try {
          // Add category to the item so News.fromJson can use it
          item['category'] = category;
          
          final article = News.fromJson(item);
          // Only add if we have essential fields
          if (article.title.isNotEmpty && article.url.isNotEmpty) {
            news.add(article);
          }
        } catch (_) {
          // Skip malformed articles
          continue;
        }
      }

      if (news.isEmpty) {
        throw NewsApiException('No articles available for this category');
      }

      return news;
    } on NewsApiException {
      rethrow;
    } catch (e) {
      throw NewsApiException('Error fetching news: $e');
    }
  }

  Map<String, dynamic> _decodeJson(String text) {
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } on FormatException {
      throw NewsApiException('Invalid JSON response from GNews API');
    }
  }

  String _formatError(http.Response response) {
    final code = response.statusCode;

    // Try to parse error message from response
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final message = body['message'] as String?;
      if (message != null && message.isNotEmpty) {
        return 'NewsAPI error ($code): $message';
      }
    } catch (_) {
      // ignore
    }

    // Standard HTTP error messages
    switch (code) {
      case 400:
        return 'NewsAPI error: Bad request - check parameters';
      case 401:
        return 'NewsAPI error: Invalid API key. Get one at https://newsapi.org/';
      case 403:
        return 'NewsAPI error: Access forbidden';
      case 429:
        return 'NewsAPI error: Rate limit exceeded (100/day free tier) - try again tomorrow';
      case 500:
        return 'NewsAPI error: Server error - try again later';
      default:
        return 'NewsAPI request failed ($code)';
    }
  }
}
