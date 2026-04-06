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

/// Fetches headlines from [World News API](https://worldnewsapi.com/).
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

  static const _authority = 'api.worldnewsapi.com';
  static const _userAgent = 'SmartNews/1.0 (Flutter; student app)';

  /// Maps UI chip labels to API behavior.
  Future<List<News>> fetchForCategory(String categoryLabel) async {
    if (!ApiConfig.hasNewsApiKey) {
      throw NewsApiException(
        'Missing WorldNewsAPI key. Use --dart-define=NEWS_API_KEY=your_key '
        'or set kNewsApiKey in lib/config/api_secrets.dart.',
      );
    }

    switch (categoryLabel) {
      default:
        return _fetchWorldNews(categoryLabel: categoryLabel);
    }
  }

  Future<List<News>> _fetchWorldNews({required String categoryLabel}) async {
    // WorldNewsAPI doesn't have the same category endpoints as NewsAPI.org.
    // We'll use Top News for "All" and Search News for other chips.
    if (categoryLabel == 'All') {
      final uri = Uri.https(_authority, '/top-news', {
        'api-key': ApiConfig.newsApiKey,
        'source-country': 'us',
        'language': 'en',
      });
      return _getTopNews(uri);
    }

    final query = categoryLabel.toLowerCase();
    final uri = Uri.https(_authority, '/search-news', {
      'api-key': ApiConfig.newsApiKey,
      'text': query,
      'language': 'en',
      'source-countries': 'us',
      'number': '30',
      'offset': '0',
    });
    return _getSearchNews(uri);
  }

  Future<List<News>> _getTopNews(Uri uri) async {
    final response = await _client.get(uri, headers: {'User-Agent': _userAgent});
    if (response.statusCode != 200) {
      throw NewsApiException(_worldError(response));
    }

    final body = _decodeJson(response.body);
    final top = body['top_news'] as List<dynamic>? ?? [];
    final out = <News>[];
    for (final cluster in top) {
      if (cluster is! Map<String, dynamic>) continue;
      final news = cluster['news'] as List<dynamic>? ?? [];
      for (final item in news) {
        if (item is! Map<String, dynamic>) continue;
        final article = News.fromJson(item);
        if (article.title.isEmpty) continue;
        out.add(article);
      }
    }
    return out;
  }

  Future<List<News>> _getSearchNews(Uri uri) async {
    final response = await _client.get(uri, headers: {'User-Agent': _userAgent});
    if (response.statusCode != 200) {
      throw NewsApiException(_worldError(response));
    }

    final body = _decodeJson(response.body);
    final raw = body['news'] as List<dynamic>? ?? [];
    final out = <News>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final article = News.fromJson(item);
      if (article.title.isEmpty) continue;
      out.add(article);
    }
    return out;
  }

  Map<String, dynamic> _decodeJson(String text) {
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } on FormatException {
      throw NewsApiException('Invalid response from WorldNewsAPI.');
    }
  }

  String _worldError(http.Response response) {
    final code = response.statusCode;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = body['message'] as String?;
      if (msg != null && msg.isNotEmpty) {
        return 'WorldNewsAPI error ($code): $msg';
      }
    } catch (_) {
      // ignore
    }
    return 'WorldNewsAPI request failed ($code).';
  }

  // No placeholder filter needed for WorldNewsAPI.
}
