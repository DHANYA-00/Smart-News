import 'package:flutter/material.dart';

class QuizScoreCard extends StatelessWidget {
  const QuizScoreCard({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onRetake,
    required this.onNewQuiz,
    required this.questions,
    required this.userAnswers,
  });

  final int score;
  final int totalQuestions;
  final VoidCallback onRetake;
  final VoidCallback onNewQuiz;
  final List<Map<String, dynamic>> questions;
  final List<int> userAnswers;

  String _getMotivationalMessage() {
    final percentage = (score / totalQuestions) * 100;

    if (percentage == 100) {
      return '🌟 Perfect Score! You are a Current Affairs Expert!';
    } else if (percentage >= 80) {
      return '🎉 Excellent! Keep it up!';
    } else if (percentage >= 60) {
      return '👍 Good job! Review the topics you missed.';
    } else if (percentage >= 40) {
      return '💪 Nice effort! Practice more for better results.';
    } else {
      return '📖 Keep learning! You\'ll improve with practice.';
    }
  }

  Color _getScoreColor() {
    final percentage = (score / totalQuestions) * 100;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score circle
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getScoreColor().withValues(alpha: 0.15),
                border: Border.all(
                  color: _getScoreColor(),
                  width: 3,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score/$totalQuestions',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: _getScoreColor(),
                      ),
                    ),
                    Text(
                      '${((score / totalQuestions) * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _getScoreColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Motivational message
            Text(
              _getMotivationalMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            // Results breakdown
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Correct answers
                  for (int i = 0; i < questions.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i < questions.length - 1 ? 16 : 0,
                      ),
                      child: _buildResultRow(i),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onNewQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'New Quiz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetake,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.blue),
                    ),
                    child: const Text(
                      'Retake',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(int questionIndex) {
    final isCorrect = userAnswers[questionIndex] == questions[questionIndex]['correctAnswer'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Q${questionIndex + 1}: ${questions[questionIndex]['question']}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        if (!isCorrect) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              'Correct: ${String.fromCharCode(65 + (questions[questionIndex]['correctAnswer'] as int))}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ),
        ],
        if ((questions[questionIndex]['explanation'] as String? ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Text(
              '${questions[questionIndex]['explanation']}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}
