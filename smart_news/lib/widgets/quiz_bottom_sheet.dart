import 'package:flutter/material.dart';
import '../services/quiz_generation_service.dart';
import '../services/quiz_cache.dart';

/// Interactive quiz bottom sheet with feedback and scoring
class QuizBottomSheet extends StatefulWidget {
  final String articleId;
  final String articleTitle;
  final String articleContent;
  final String language;
  final QuizGenerationService quizGenerationService;
  final QuizCache quizCache;
  final VoidCallback? onQuizComplete;

  const QuizBottomSheet({
    super.key,
    required this.articleId,
    required this.articleTitle,
    required this.articleContent,
    required this.language,
    required this.quizGenerationService,
    required this.quizCache,
    this.onQuizComplete,
  });

  @override
  State<QuizBottomSheet> createState() => _QuizBottomSheetState();
}

class _QuizBottomSheetState extends State<QuizBottomSheet> {
  late Future<List<QuizQuestion>> _quizFuture;
  late List<String?> _selectedAnswers;
  late List<bool> _answered;
  int _currentQuestion = 0;

  @override
  void initState() {
    super.initState();
    _quizFuture = _loadQuiz();
  }

  Future<List<QuizQuestion>> _loadQuiz() async {
    // Always generate fresh questions — no cache so questions never repeat
    final quiz = await widget.quizGenerationService.generateQuiz(
      title: widget.articleTitle,
      content: widget.articleContent,
      language: widget.language,
    );
    _initAnswerTracking(quiz.length);
    return quiz;
  }

  void _initAnswerTracking(int questionCount) {
    _selectedAnswers = List<String?>.filled(questionCount, null);
    _answered = List<bool>.filled(questionCount, false);
  }

  void _selectAnswer(String answer) {
    if (!_answered[_currentQuestion]) {
      setState(() {
        _selectedAnswers[_currentQuestion] = answer;
        _answered[_currentQuestion] = true;
      });
    }
  }

  void _goToNextQuestion(int totalQuestions) {
    if (_currentQuestion < totalQuestions - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      // Quiz complete
      _showResults();
    }
  }

  void _showResults() {
    _quizFuture.then((quiz) {
      if (!mounted) return;
      
      int score = 0;
      for (int i = 0; i < quiz.length; i++) {
        if (_selectedAnswers[i] == quiz[i].correctAnswer) {
          score++;
        }
      }

      widget.quizCache.recordScore(widget.articleId, score, quiz.length);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _QuizResultDialog(
          score: score,
          total: quiz.length,
          onClose: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Close bottom sheet
            widget.onQuizComplete?.call();
          },
          streak: widget.quizCache.getStreak(),
          totalScore: widget.quizCache.getTotalScore(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Article Quiz',
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.articleTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Flexible(
            child: FutureBuilder<List<QuizQuestion>>(
              future: _quizFuture,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Generating quiz questions...',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to generate quiz',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              _quizFuture = _loadQuiz();
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Success state
                if (snapshot.hasData) {
                  final quiz = snapshot.data!;
                  final currentQ = quiz[_currentQuestion];
                  final selected = _selectedAnswers[_currentQuestion];
                  final hasAnswered = _answered[_currentQuestion];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress indicator
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: (_currentQuestion + 1) / quiz.length,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_currentQuestion + 1}/${quiz.length}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Question
                        Text(
                          currentQ.question,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Options
                        ...currentQ.options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
                          final isSelected = selected == optionLetter;
                          final isCorrect = currentQ.correctAnswer == optionLetter;

                          Color? backgroundColor;
                          Color? borderColor;

                          if (hasAnswered) {
                            if (isCorrect) {
                              backgroundColor = Colors.green.withValues(alpha: 0.1);
                              borderColor = Colors.green;
                            } else if (isSelected && !isCorrect) {
                              backgroundColor = Colors.red.withValues(alpha: 0.1);
                              borderColor = Colors.red;
                            }
                          } else if (isSelected) {
                            backgroundColor =
                                theme.colorScheme.primary.withValues(alpha: 0.1);
                            borderColor = theme.colorScheme.primary;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: hasAnswered ? null : () => _selectAnswer(optionLetter),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: borderColor ??
                                        theme.colorScheme.outlineVariant,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: backgroundColor,
                                ),
                                child: Row(
                                  children: [
                                    if (hasAnswered && isCorrect)
                                      Icon(Icons.check_circle,
                                          color: Colors.green)
                                    else if (hasAnswered && isSelected && !isCorrect)
                                      Icon(Icons.cancel, color: Colors.red)
                                    else
                                      Opacity(
                                        opacity: 0.5,
                                        child: Text(
                                          optionLetter,
                                          style:
                                              theme.textTheme.labelLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option.replaceFirst('$optionLetter. ', ''),
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 24),

                        // Next button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: hasAnswered
                                ? () => _goToNextQuestion(quiz.length)
                                : null,
                            child: Text(_currentQuestion == quiz.length - 1
                                ? 'Finish Quiz'
                                : 'Next Question'),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Results dialog showing score and gamification stats
class _QuizResultDialog extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onClose;
  final int streak;
  final int totalScore;

  const _QuizResultDialog({
    required this.score,
    required this.total,
    required this.onClose,
    required this.streak,
    required this.totalScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = ((score / total) * 100).toStringAsFixed(0);
    final isFullScore = score == total;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFullScore ? Icons.celebration : Icons.done_all,
              size: 64,
              color: isFullScore ? Colors.amber : theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Quiz Complete!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$score of $total correct',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            // Gamification stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.local_fire_department,
                              color: Colors.orange, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Streak',
                            style: theme.textTheme.labelSmall,
                          ),
                          Text(
                            '$streak',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Total Score',
                            style: theme.textTheme.labelSmall,
                          ),
                          Text(
                            '$totalScore',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onClose,
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show quiz bottom sheet
void showQuizBottomSheet({
  required BuildContext context,
  required String articleId,
  required String articleTitle,
  required String articleContent,
  required String language,
  required QuizGenerationService quizGenerationService,
  required QuizCache quizCache,
  VoidCallback? onQuizComplete,
}) {
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => QuizBottomSheet(
      articleId: articleId,
      articleTitle: articleTitle,
      articleContent: articleContent,
      language: language,
      quizGenerationService: quizGenerationService,
      quizCache: quizCache,
      onQuizComplete: onQuizComplete,
    ),
  );
}
