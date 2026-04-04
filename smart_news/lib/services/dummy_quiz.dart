import '../models/quiz_question.dart';

/// One sample quiz for the whole app (good enough to learn UI + navigation).
final List<QuizQuestion> dummyQuizQuestions = [
  const QuizQuestion(
    question: 'What is the main purpose of active recall when studying?',
    options: [
      'To reread notes slowly',
      'To test yourself from memory',
      'To highlight everything',
      'To avoid taking breaks',
    ],
    correctIndex: 1,
  ),
  const QuizQuestion(
    question: 'Which practice usually improves long-term retention?',
    options: [
      'Cramming the night before',
      'Spaced repetition over time',
      'Skipping sleep',
      'Only reading titles',
    ],
    correctIndex: 1,
  ),
  const QuizQuestion(
    question: 'A good news habit for students is to:',
    options: [
      'Trust one headline without sources',
      'Check multiple reputable sources',
      'Share before reading',
      'Ignore dates on articles',
    ],
    correctIndex: 1,
  ),
];