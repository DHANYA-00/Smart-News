import 'package:flutter/material.dart';

import '../models/quiz_question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.questions});

  final List<QuizQuestion> questions;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int? _selectedOption;
  int _score = 0;
  bool _finished = false;

  QuizQuestion get _current => widget.questions[_index];

  void _onNext() {
    if (_finished) return;

    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick an answer first')),
      );
      return;
    }

    if (_selectedOption == _current.correctIndex) {
      _score++;
    }

    final isLast = _index >= widget.questions.length - 1;
    if (isLast) {
      setState(() => _finished = true);
      return;
    }

    setState(() {
      _index++;
      _selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
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
        const SizedBox(height: 12),
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
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                backgroundColor: selected
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => setState(() => _selectedOption = i),
              child: Text(q.options[i]),
            ),
          );
        }),
        const Spacer(),
        FilledButton(
          onPressed: _onNext,
          child: Text(
            _index >= widget.questions.length - 1 ? 'Finish' : 'Next',
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResult(ThemeData theme) {
    final total = widget.questions.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.emoji_events_outlined,
          size: 72,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Your score',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_score / $total',
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to article'),
        ),
      ],
    );
  }
}