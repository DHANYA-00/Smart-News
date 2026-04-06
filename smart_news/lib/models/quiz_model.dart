class QuizItem {
  const QuizItem({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final String answer;
  final String explanation;

  int get correctIndex {
    final normalized = answer.trim().toUpperCase();
    if (normalized.length == 1) {
      const letters = ['A', 'B', 'C', 'D'];
      final index = letters.indexOf(normalized);
      if (index >= 0 && index < options.length) {
        return index;
      }
    }

    for (var i = 0; i < options.length; i++) {
      if (options[i].trim().toLowerCase() == answer.trim().toLowerCase()) {
        return i;
      }
    }
    return 0;
  }

  String get correctOptionLabel => options[correctIndex];

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List<dynamic>? ?? []).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();

    final options = <String>[...rawOptions];
    while (options.length < 4) {
      options.add('Option ${String.fromCharCode(65 + options.length)}');
    }

    return QuizItem(
      question: (json['question'] as String? ?? 'Untitled question').trim(),
      options: options.take(4).toList(),
      answer: (json['answer'] as String? ?? 'A').trim(),
      explanation: (json['explanation'] as String? ?? 'No explanation provided.').trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'answer': answer,
        'explanation': explanation,
      };
}

