class News {
  const News({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.content,
    required this.sourceName,
    required this.url,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String content;
  final String sourceName;
  final String url;

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
    // Supports both NewsAPI.org and WorldNewsAPI.com shapes.
    final url = (json['url'] as String?)?.trim() ?? '';

    final title = (json['title'] as String?)?.trim() ?? 'Untitled';

    // WorldNewsAPI: summary/text/image/publish_date
    // NewsAPI: description/content/urlToImage/publishedAt
    final description =
        ((json['summary'] ?? json['description']) as String?)?.trim() ?? '';
    final content = ((json['text'] ?? json['content']) as String?)?.trim() ?? '';

    final rawImage = (json['image'] ?? json['urlToImage']) as String?;
    final imageUrl = (rawImage != null && rawImage.trim().isNotEmpty)
        ? rawImage.trim()
        : '';

    String sourceName = 'Unknown source';
    if (json['source'] is Map<String, dynamic>) {
      final source = json['source'] as Map<String, dynamic>;
      sourceName = (source['name'] as String?)?.trim() ?? sourceName;
    } else if (url.isNotEmpty) {
      final host = Uri.tryParse(url)?.host;
      if (host != null && host.isNotEmpty) {
        sourceName = host.replaceFirst('www.', '');
      }
    }

    final published =
        (json['publish_date'] ?? json['publishedAt']) as String? ?? '';
    final id = url.isNotEmpty ? url : published;

    return News(
      id: id.isNotEmpty ? id : title,
      title: title,
      description: description,
      imageUrl: imageUrl,
      content: content,
      sourceName: sourceName,
      url: url,
    );
  }
}
