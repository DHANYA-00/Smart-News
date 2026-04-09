import 'package:flutter/material.dart';

import '../models/news_model.dart';
import '../services/bookmarks_service.dart';
import 'news_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarksService _bookmarksService = BookmarksService.instance;
  late List<News> _bookmarks;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    await _bookmarksService.init();
    if (mounted) {
      final bookmarks = await _bookmarksService.getBookmarks();
      setState(() {
        _bookmarks = bookmarks;
        _loading = false;
      });
    }
  }

  Future<void> _removeBookmark(String articleId) async {
    await _bookmarksService.removeBookmark(articleId);
    await _loadBookmarks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark removed')),
      );
    }
  }

  Future<void> _confirmRemove(News article) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Bookmark?'),
        content: Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _removeBookmark(article.id);
    }
  }

  Future<void> _clearAllBookmarks() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Bookmarks?'),
        content: const Text(
          'This will permanently delete all bookmarked articles. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _bookmarksService.clearAllBookmarks();
      await _loadBookmarks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All bookmarks cleared')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bookmarks')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks${_bookmarks.isNotEmpty ? '  (${_bookmarks.length})' : ''}',
        ),
        actions: [
          if (_bookmarks.isNotEmpty)
            IconButton(
              onPressed: _clearAllBookmarks,
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: _bookmarks.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: _bookmarks.length,
              itemBuilder: (context, index) {
                final article = _bookmarks[index];

                // Swipe left to delete
                return Dismissible(
                  key: ValueKey(article.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('Remove Bookmark?'),
                        content: Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Remove',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    return ok == true;
                  },
                  onDismissed: (_) => _removeBookmark(article.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline,
                            color: theme.colorScheme.onErrorContainer),
                        const SizedBox(width: 6),
                        Text('Remove',
                            style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  child: _buildArticleCard(context, theme, article),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline_rounded,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('No bookmarks yet',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Articles you bookmark will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    ThemeData theme,
    News article,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => NewsDetailScreen(news: article),
            ),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: article.imageUrl.isNotEmpty
                      ? Image.network(
                          article.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _placeholderImage(theme),
                        )
                      : _placeholderImage(theme),
                ),
                const SizedBox(width: 12),

                // Title + Source + Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.sourceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      if (article.publishedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(article.publishedAt!),
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Explicit delete button ──────────────────────────────
                IconButton(
                  onPressed: () => _confirmRemove(article),
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 20, color: theme.colorScheme.error),
                  tooltip: 'Remove bookmark',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.article_outlined, color: theme.colorScheme.outline),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}