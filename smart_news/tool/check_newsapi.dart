import 'dart:convert';

import 'package:http/http.dart' as http;

import '../lib/config/api_config.dart';

Future<void> main() async {
  if (!ApiConfig.hasNewsApiKey) {
    print('FAIL: NEWS_API_KEY is missing.');
    return;
  }

  final uri = Uri.https('api.worldnewsapi.com', '/top-news', {
    'api-key': ApiConfig.newsApiKey,
    'source-country': 'us',
    'language': 'en',
  });

  try {
    final res = await http.get(uri, headers: {
      'User-Agent': 'SmartNews/NewsKeyCheck',
    });

    if (res.statusCode != 200) {
      print('FAIL: HTTP ${res.statusCode}');
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final msg = body['message'] as String?;
        if (msg != null && msg.isNotEmpty) {
          print('Reason: $msg');
        }
      } catch (_) {
        // ignore
      }
      return;
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final topNews = body['top_news'] as List<dynamic>?;
    final clusters = topNews?.length ?? 0;
    print('OK: WorldNewsAPI key works. clusters=$clusters');
  } catch (e) {
    print('FAIL: Network error. ${e.runtimeType}');
  }
}

