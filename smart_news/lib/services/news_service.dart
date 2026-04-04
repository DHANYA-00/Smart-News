import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/news_model.dart';

class NewsApiException implements Exception {
  NewsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Fetches headlines from [NewsAPI.org](https://newsapi.org).
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

  /// Maps UI chip labels to API behavior.
  Future<List<News>> fetchForCategory(String categoryLabel) async {
    if (!ApiConfig.hasNewsApiKey) {
      throw NewsApiException(
        'Missing News API key. Use --dart-define=NEWS_API_KEY=your_key '
        'or set kNewsApiKey in lib/config/api_secrets.dart.',
      );
    }

    switch (categoryLabel) {
      case 'Education':
        return _fetchEverything(query: 'education');
      case 'Politics':
        return _fetchEverything(query: 'politics');
      default:
        return _fetchTopHeadlines(categoryLabel: categoryLabel);
    }
  }

  /// Top headlines for [All], [Sports], [Tech], or [Business] (if you add it).
  Future<List<News>> _fetchTopHeadlines({required String categoryLabel}) async {
    final params = <String, String>{
      'country': 'us',
      'pageSize': '30',
      'apiKey': ApiConfig.newsApiKey,
    };

    final apiCategory = _topHeadlinesCategoryParam(categoryLabel);
    if (apiCategory != null) {
      params['category'] = apiCategory;
    }

    final uri = Uri.https(_authority, '/v2/top-headlines', params);
    return _getArticles(uri);
  }

  /// NewsAPI top-headlines supports: business, entertainment, general, health,
  /// science, sports, technology. [All] omits category.
  String? _topHeadlinesCategoryParam(String label) {
    switch (label) {
      case 'Sports':
        return 'sports';
      case 'Tech':
        return 'technology';
      case 'Business':
        return 'business';
      default:
        return null;
    }
  }

  Future<List<News>> _fetchEverything({required String query}) async {
    final uri = Uri.https(_authority, '/v2/everything', {
      'q': query,
      'language': 'en',
      'sortBy': 'publishedAt',
      'pageSize': '30',
      'apiKey': ApiConfig.newsApiKey,
    });
    return _getArticles(uri);
  }

  Future<List<News>> _getArticles(Uri uri) async {
    final response = await _client.get(
      uri,
      headers: {'User-Agent': _userAgent},
    );

    if (response.statusCode != 200) {
      throw NewsApiException(
        'Request failed (${response.statusCode}). Please try again later.',
      );
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw NewsApiException('Invalid response from news service.');
    }

    if (body['status'] != 'ok') {
      final msg = body['message'] as String? ?? 'News service error';
      throw NewsApiException(msg);
    }

    final raw = body['articles'] as List<dynamic>? ?? [];
    final list = <News>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final article = News.fromJson(item);
      if (_isPlaceholderArticle(article.title)) continue;
      list.add(article);
    }
    return list;
  }

  bool _isPlaceholderArticle(String title) {
    final t = title.toLowerCase();
    return t.contains('[removed]');
  }
}
