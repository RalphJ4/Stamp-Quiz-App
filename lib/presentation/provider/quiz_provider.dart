import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/question.dart';
import '../../data/datasources/local_question_datasource.dart';
import '../../data/repositories/question_repository_impl.dart';
import '../../domain/usecases/get_questions.dart';

class QuizProvider extends ChangeNotifier {
  final _local = LocalQuestionDataSource();
  late final GetQuestions _getQuestions;

  QuizProvider() {
    final repo = QuestionRepositoryImpl(local: _local);
    _getQuestions = GetQuestions(repo);
  }

  List<Question> _questions = [];
  List<Question> get questions => _questions;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  int _stamps = 0;
  int get stamps => _stamps;

  bool _answered = false;
  bool get answered => _answered;

  int? _selectedOption;
  int? get selectedOption => _selectedOption;

  bool _animateStamp = false;
  bool get animateStamp => _animateStamp;

  Future<void> loadQuestions() async {
    _questions = await _getQuestions.execute();
    await _loadStamps();
    notifyListeners();
  }

  void selectOption(int index) {
    if (_answered) return;
    _selectedOption = index;
    _answered = true;

    if (_questions[_currentIndex].correctIndex == index) {
      _stamps++;
      _animateStamp = true;
      _saveStamps();
    } else {
      _animateStamp = false;
    }

    notifyListeners();
  }
  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    _answered = false;
    _selectedOption = null;
    _animateStamp = false;
    notifyListeners();
  }

  void resetQuiz() {
    _currentIndex = 0;
    _stamps = 0;
    _answered = false;
    _selectedOption = null;
    _animateStamp = false;
    _saveStamps();
    notifyListeners();
  }

  Future<void> _loadStamps() async {
    final prefs = await SharedPreferences.getInstance();
    _stamps = prefs.getInt('stamps') ?? 0;
  }

  Future<void> _saveStamps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stamps', _stamps);
  }
}
