import 'package:flutter/material.dart';

import '../models/quiz_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.questions,
    this.quizTitle = 'Quiz',
  });

  final List<QuizItem> questions;
  final String quizTitle;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int? _selectedOption;
  int _score = 0;
  bool _finished = false;
  bool _showFeedback = false;
  bool _savedScore = false;

  late final List<int> _selectedAnswers;

  QuizItem get _current => widget.questions[_index];

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List<int>.filled(widget.questions.length, -1);
  }

  Future<void> _onNext() async {
    if (_finished) return;

    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick an answer first.')),
      );
      return;
    }

    if (!_showFeedback) {
      final isCorrect = _selectedOption == _current.correctIndex;
      if (isCorrect) {
        _score++;
      }
      _selectedAnswers[_index] = _selectedOption!;
      setState(() {
        _showFeedback = true;
      });
      return;
    }

    final isLast = _index >= widget.questions.length - 1;
    if (isLast) {
      setState(() => _finished = true);
      await _saveScoreOnce();
      return;
    }

    setState(() {
      _index++;
      _selectedOption = null;
      _showFeedback = false;
    });
  }

  Future<void> _saveScoreOnce() async {
    if (_savedScore) return;
    _savedScore = true;

    final user = AuthService.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      await FirestoreService.instance.addQuizScore(
        userId: user.uid,
        score: _score,
        totalQuestions: widget.questions.length,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Score not saved. Please check your connection.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _finished ? _buildResult(theme) : _buildQuestion(theme),
        ),
      ),
    );
  }

  Widget _buildQuestion(ThemeData theme) {
    final q = _current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Question ${_index + 1} of ${widget.questions.length}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_index + 1) / widget.questions.length,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 14),
        Text(
          q.question,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(q.options.length, (i) {
          final selected = _selectedOption == i;
          final isCorrect = i == q.correctIndex;
          final reveal = _showFeedback;

          Color? bg;
          if (reveal && isCorrect) {
            bg = theme.colorScheme.primaryContainer.withValues(alpha: 0.55);
          } else if (reveal && selected && !isCorrect) {
            bg = theme.colorScheme.errorContainer.withValues(alpha: 0.55);
          } else if (selected) {
            bg = theme.colorScheme.primaryContainer.withValues(alpha: 0.35);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                backgroundColor: bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _showFeedback ? null : () => setState(() => _selectedOption = i),
              child: Text(q.options[i]),
            ),
          );
        }),
        if (_showFeedback) ...[
          const SizedBox(height: 8),
          Text(
            _selectedOption == q.correctIndex
                ? 'Correct!'
                : 'Incorrect. Correct answer: ${q.correctOptionLabel}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _selectedOption == q.correctIndex
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            q.explanation,
            style: theme.textTheme.bodyMedium,
          ),
        ],
        const Spacer(),
        FilledButton(
          onPressed: _onNext,
          child: Text(
            !_showFeedback
                ? 'Check Answer'
                : (_index >= widget.questions.length - 1 ? 'Finish' : 'Next'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResult(ThemeData theme) {
    final total = widget.questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Icon(
          Icons.emoji_events_outlined,
          size: 72,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          'Your score: $_score / $total',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: widget.questions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final q = widget.questions[index];
              final selected = _selectedAnswers[index];
              final isCorrect = selected == q.correctIndex;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${q.question}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your answer: ${selected >= 0 ? q.options[selected] : 'Not answered'}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      'Correct answer: ${q.correctOptionLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isCorrect
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      q.explanation,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

