import 'package:flutter/material.dart';
import '../services/groq_service.dart';

class QuizProvider extends ChangeNotifier {
  QuizProvider(this._groqService);

  final GroqService _groqService;

  List<Map<String, dynamic>> _quizQuestions = [];
  bool _isLoading = false;
  String? _error;
  int _currentQuestionIndex = 0;
  List<int> _userAnswers = [];

  List<Map<String, dynamic>> get quizQuestions => _quizQuestions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<int> get userAnswers => _userAnswers;

  Future<void> generateQuiz(String articleText, {int numQuestions = 5}) async {
    _isLoading = true;
    _error = null;
    _quizQuestions = [];
    _currentQuestionIndex = 0;
    _userAnswers = [];
    notifyListeners();

    try {
      _quizQuestions =
          await _groqService.generateQuiz(articleText, numQuestions: numQuestions);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _quizQuestions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generate current affairs quiz from article texts
  Future<void> generateCurrentAffairsQuiz(List<String> articles) async {
    _isLoading = true;
    _error = null;
    _quizQuestions = [];
    _currentQuestionIndex = 0;
    _userAnswers = [];
    notifyListeners();

    try {
      final questions =
          await _groqService.generateCurrentAffairsQuiz(articles);

      // Convert questions to the expected format
      _quizQuestions = questions.map((q) {
        // Parse correct answer from letter (A, B, C, D) to index (0, 1, 2, 3)
        final correctLetter = (q['correct'] as String? ?? 'A').trim().toUpperCase();
        final correctIndex = correctLetter.codeUnitAt(0) - 65;

        return {
          'question': q['question'] ?? '',
          'options': q['options'] ?? [],
          'correctAnswer': correctIndex.clamp(0, 3),
          'explanation': q['explanation'] ?? '',
        };
      }).toList();

      _error = null;
    } catch (e) {
      _error = e.toString();
      _quizQuestions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAnswer(int answerIndex) {
    if (_userAnswers.length <= _currentQuestionIndex) {
      _userAnswers.add(answerIndex);
    } else {
      _userAnswers[_currentQuestionIndex] = answerIndex;
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  int getScore() {
    int correct = 0;
    for (int i = 0; i < _userAnswers.length; i++) {
      if (_userAnswers[i] ==
          _quizQuestions[i]['correctAnswer'] as int) {
        correct++;
      }
    }
    return correct;
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _userAnswers = [];
    _error = null;
    notifyListeners();
  }

  void clearQuiz() {
    _quizQuestions = [];
    _currentQuestionIndex = 0;
    _userAnswers = [];
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
