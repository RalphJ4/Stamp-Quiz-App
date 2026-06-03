import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/question.dart';
import '../../data/datasources/local_question_datasource.dart';
import '../../data/repositories/question_repository_impl.dart';
import '../../domain/usecases/get_questions.dart';

class CategoryStats {
  final String category;
  final int stamps;

  const CategoryStats({required this.category, required this.stamps});
}

class QuizProvider extends ChangeNotifier {
  final _local = LocalQuestionDataSource();
  late final GetQuestions _getQuestions;

  QuizProvider() {
    final repo = QuestionRepositoryImpl(local: _local);
    _getQuestions = GetQuestions(repo);
  }

  List<Question> _allQuestions = [];
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

  bool _isQuizFinished = false;
  bool get isQuizFinished => _isQuizFinished;

  bool _quizStarted = false;
  bool get isQuizInProgress => _quizStarted && !_isQuizFinished;

  QuestionCategory _selectedCategory = QuestionCategory.space;
  QuestionCategory get selectedCategory => _selectedCategory;

  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  int _bestStreak = 0;
  int get bestStreak => _bestStreak;

  int _totalCorrect = 0;
  int get totalCorrect => _totalCorrect;

  int _totalAnswered = 0;
  int get totalAnswered => _totalAnswered;

  Future<void> loadQuestions() async {
    _allQuestions = await _getQuestions.execute();
    await _loadStats();
    _filterByCategory(_selectedCategory);
    notifyListeners();
  }

  void selectCategory(QuestionCategory category) {
    _selectedCategory = category;
    _filterByCategory(category);
    notifyListeners();
  }

  void _filterByCategory(QuestionCategory category) {
    _questions = _allQuestions.where((q) => q.category == category).toList();
    _currentIndex = 0;
    _answered = false;
    _selectedOption = null;
    _animateStamp = false;
    _isQuizFinished = false;
    _quizStarted = false;
    notifyListeners();
  }

  int getCategoryStamps(QuestionCategory category) {
    return 0;
  }

  List<CategoryStats> get allCategoryStats {
    return QuestionCategory.values.map((cat) {
      final count = _allQuestions.where((q) => q.category == cat).length;
      return CategoryStats(category: cat.name, stamps: count);
    }).toList();
  }

  void selectOption(int index) {
    if (_answered) return;
    _quizStarted = true;
    _selectedOption = index;
    _answered = true;
    _totalAnswered++;

    if (_questions[_currentIndex].correctIndex == index) {
      final reward = _questions[_currentIndex].stampReward;
      _stamps += reward;
      _currentStreak++;
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
      }
      _totalCorrect++;
      _animateStamp = true;
      _saveStats();
    } else {
      _currentStreak = 0;
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

  void finishQuiz() {
    _isQuizFinished = true;
    notifyListeners();
  }

  Future<void> resetQuiz() async {
    _currentIndex = 0;
    _stamps = 0;
    _answered = false;
    _selectedOption = null;
    _animateStamp = false;
    _isQuizFinished = false;
    _quizStarted = false;
    _currentStreak = 0;
    _bestStreak = 0;
    _totalCorrect = 0;
    _totalAnswered = 0;
    await _saveStats();
    await loadQuestions();
    notifyListeners();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    _bestStreak = prefs.getInt('bestStreak') ?? 0;
    _totalCorrect = prefs.getInt('totalCorrect') ?? 0;
    _totalAnswered = prefs.getInt('totalAnswered') ?? 0;
    _stamps = prefs.getInt('stamps') ?? 0;
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stamps', _stamps);
    await prefs.setInt('bestStreak', _bestStreak);
    await prefs.setInt('totalCorrect', _totalCorrect);
    await prefs.setInt('totalAnswered', _totalAnswered);
  }
}
