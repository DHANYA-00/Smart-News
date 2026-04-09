import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/news_model.dart';
import '../services/quiz_generation_service.dart';
import '../services/quiz_cache.dart';
import 'quiz_bottom_sheet.dart';
import 'summary_bottom_sheet.dart';
import '../services/summarization_service.dart';
import '../services/summary_cache.dart';

class EnhancedNewsCard extends StatelessWidget {
  const EnhancedNewsCard({
    super.key,
    required this.article,
    required this.onReadMore,
    this.currentCategory,
    this.quizGenerationService,
    this.quizCache,
    this.userLanguage = 'English',
    this.summarizationService,
    this.summaryCache,
  });

  final News article;
  final VoidCallback onReadMore;
  final String? currentCategory;
  final QuizGenerationService? quizGenerationService;
  final QuizCache? quizCache;
  final String userLanguage;
  final SummarizationService? summarizationService;
  final SummaryCache? summaryCache;

  Color _getCategoryColor(BuildContext context, String category) {
    final primary = Theme.of(context).colorScheme.primary;
    switch (category.toLowerCase()) {
      case 'sports':        return const Color(0xFF34A853);
      case 'politics':      return const Color(0xFFFBBC04);
      case 'technology':    return primary;
      case 'business':      return const Color(0xFFEA4335);
      case 'science':       return const Color(0xFF4285F4);
      case 'health':        return const Color(0xFF34A853);
      case 'entertainment': return const Color(0xFFAA00FF);
      default:              return const Color(0xFF5F6368);
    }
  }

  String _getCategory() {
    if (article.category.isNotEmpty && article.category != 'general') {
      return article.category[0].toUpperCase() + article.category.substring(1);
    }
    return 'General';
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return 'Recently';
    return timeago.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final category = _getCategory();
    final catColor = _getCategoryColor(context, category);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          onTap: onReadMore,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Category + India badge ────────────────────────────────
                Row(
                  children: [
                    _Badge(label: category, color: catColor),
                    if (currentCategory == 'India') ...[
                      const SizedBox(width: 8),
                      _Badge(
                        label: '🇮🇳 India',
                        color: theme.colorScheme.primary,
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _getTimeAgo(article.publishedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Headline ──────────────────────────────────────────────
                Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),

                // ── Source ────────────────────────────────────────────────
                Text(
                  article.sourceName.isEmpty ? 'Unknown Source' : article.sourceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Action buttons ────────────────────────────────────────
                Row(
                  children: [
                    // Summarize News button
                    if (summarizationService != null && summaryCache != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showSummaryBottomSheet(
                              context: context,
                              articleId: article.id,
                              articleTitle: article.title,
                              articleContent: '${article.description}\n\n${article.content}\n\nSource: ${article.sourceName}',
                              language: userLanguage,
                              summarizationService: summarizationService!,
                              summaryCache: summaryCache!,
                            );
                          },
                          icon: const Icon(Icons.summarize_rounded, size: 15),
                          label: const Text("What's this?"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                            foregroundColor: theme.colorScheme.onSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      )
                    else 
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReadMore,
                          icon: const Icon(Icons.open_in_new_rounded, size: 15),
                          label: const Text('Read Article'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                            foregroundColor: theme.colorScheme.onSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                    // Take Quiz button (only when services provided)
                    if (quizGenerationService != null && quizCache != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            showQuizBottomSheet(
                              context: context,
                              articleId: article.id,
                              articleTitle: article.title,
                              articleContent: article.detailBody,
                              language: userLanguage,
                              quizGenerationService: quizGenerationService!,
                              quizCache: quizCache!,
                            );
                          },
                          icon: const Icon(Icons.quiz_rounded, size: 15),
                          label: const Text('Take Quiz'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            backgroundColor:
                                const Color(0xFFFBBC04).withValues(alpha: 0.15),
                            foregroundColor: const Color(0xFFB8860B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                  color: Color(0xFFFBBC04), width: 0.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
