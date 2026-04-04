class News {
  const News({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.content,
    required this.sourceName,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String content;
  final String sourceName;

  /// Summary for list cards (short).
  String get cardDescription {
    final d = description.trim();
    if (d.isNotEmpty) return d;
    final c = content.trim();
    if (c.isEmpty) return 'Tap to read more';
    return c.length > 160 ? '${c.substring(0, 160)}…' : c;
  }

  /// Body for detail screen.
  String get detailBody {
    final c = content.trim();
    if (c.isNotEmpty) return c;
    final d = description.trim();
    if (d.isNotEmpty) return d;
    return 'No article text available for this story.';
  }

  factory News.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String? ?? '';
    final published = json['publishedAt'] as String? ?? '';
    final id = url.isNotEmpty ? url : published;

    final source = json['source'] as Map<String, dynamic>?;
    final sourceName = source?['name'] as String? ?? 'Unknown source';

    final rawImage = json['urlToImage'] as String?;
    final imageUrl = (rawImage != null && rawImage.isNotEmpty) ? rawImage : '';

    final title = (json['title'] as String?)?.trim() ?? 'Untitled';
    final description = (json['description'] as String?)?.trim() ?? '';
    final content = (json['content'] as String?)?.trim() ?? '';

    return News(
      id: id.isNotEmpty ? id : title,
      title: title,
      description: description,
      imageUrl: imageUrl,
      content: content,
      sourceName: sourceName,
    );
  }
}
