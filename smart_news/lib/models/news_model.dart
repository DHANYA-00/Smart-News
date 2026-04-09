class News {
  const News({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.content,
    required this.sourceName,
    required this.url,
    required this.category,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String content;
  final String sourceName;
  final String url;
  final String category;
  final DateTime? publishedAt;

  /// Summary for list cards (short).
  String get cardDescription {
    final d = description.trim();
    if (d.isNotEmpty) return d;
    final c = content.trim();
    if (c.isEmpty) return 'Tap to read more';
    return c.length > 160 ? '${c.substring(0, 160)}?' : c;
  }

  /// Body for detail screen (description + content combined when possible).
  String get detailBody {
    final desc = description.trim();
    final body = content.trim();

    if (desc.isEmpty && body.isEmpty) {
      return 'No article text available for this story.';
    }

    if (desc.isEmpty) return body;
    if (body.isEmpty) return desc;

    if (body.toLowerCase().startsWith(desc.toLowerCase())) {
      return body;
    }

    return '$desc\n\n$body';
  }

  factory News.fromJson(Map<String, dynamic> json) {
    // Supports GNews, NewsData.io, NewsAPI.org, and WorldNewsAPI.com shapes.
    
    // Get URL (different APIs use different field names)
    final url = (json['url'] ?? 
                json['link'] ?? 
                json['source_url'] ?? 
                (json['article_id'] as String?)?.trim() ?? 
                '') as String?;
    final finalUrl = (url?.trim() ?? '').isEmpty 
        ? (json['article_id'] as String?)?.trim() ?? ''
        : url?.trim() ?? '';

    // Get title
    final title = (json['title'] as String?)?.trim() ?? 'Untitled';

    // Get description (multiple field name possibilities)
    final description = ((json['description'] ?? 
                         json['summary'] ?? 
                         json['synopsis']) as String?)?.trim() ?? '';
    
    // Get content (multiple field name possibilities)
    final content = ((json['content'] ?? 
                     json['text'] ?? 
                     json['article_content']) as String?)?.trim() ?? '';

    // Get image URL (multiple field names)
    final rawImage = (json['image'] ?? 
                     json['image_url'] ?? 
                     json['urlToImage']) as String?;
    final imageUrl = (rawImage != null && rawImage.trim().isNotEmpty)
        ? rawImage.trim()
        : '';

    // Get source name (GNews: source.name, others: string or object)
    String sourceName = 'Unknown source';
    if (json['source'] is Map<String, dynamic>) {
      final source = json['source'] as Map<String, dynamic>;
      sourceName = (source['name'] as String?)?.trim() ?? sourceName;
    } else if (json['source_name'] is String) {
      sourceName = (json['source_name'] as String?)?.trim() ?? sourceName;
    } else if (finalUrl.isNotEmpty) {
      final host = Uri.tryParse(finalUrl)?.host;
      if (host != null && host.isNotEmpty) {
        sourceName = host.replaceFirst('www.', '');
      }
    }

    // Get published date
    final published = (json['publishedAt'] ?? 
                       json['pubDate'] ?? 
                       json['publish_date']) as String? ?? '';
    
    DateTime? publishedAt;
    if (published.isNotEmpty) {
      try {
        publishedAt = DateTime.parse(published);
      } catch (e) {
        publishedAt = null;
      }
    }
    
    // Get category (NewsAPI provides this)
    final category = (json['category'] as String?)?.trim() ?? 'general';
    
    // Create ID (priority: article_id > url > published > title)
    String id;
    if (json['article_id'] is String && (json['article_id'] as String).isNotEmpty) {
      id = (json['article_id'] as String).trim();
    } else if (finalUrl.isNotEmpty) {
      id = finalUrl;
    } else if (published.isNotEmpty) {
      id = published;
    } else {
      id = title;
    }

    return News(
      id: id.isNotEmpty ? id : title,
      title: title,
      description: description,
      imageUrl: imageUrl,
      content: content,
      sourceName: sourceName,
      url: finalUrl,
      category: category,
      publishedAt: publishedAt,
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'content': content,
      'sourceName': sourceName,
      'url': url,
      'category': category,
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }
}
