import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/power_up.dart';
import '../../domain/entities/question.dart';
import '../../data/datasources/local_question_datasource.dart';
import '../../data/repositories/question_repository_impl.dart';
import '../../domain/usecases/get_questions.dart';
import '../../services/auth_mode_manager.dart';
import 'power_up_provider.dart';

class CategoryStats {
  final String category;
  final int stamps;

  const CategoryStats({required this.category, required this.stamps});
}

class QuizProvider extends ChangeNotifier {
  final _local = LocalQuestionDataSource();
  late final GetQuestions _getQuestions;
  final AuthModeManager _authManager;
  String? _lastUserId;
  PowerUpProvider? _powerUpProvider;

  QuizProvider(this._authManager) {
    final repo = QuestionRepositoryImpl(local: _local);
    _getQuestions = GetQuestions(repo);
    _authManager.addListener(_onAuthChanged);
    _loadStats();
  }

  void attachPowerUpProvider(PowerUpProvider provider) {
    _powerUpProvider = provider;
  }

  @override
  void dispose() {
    _authManager.removeListener(_onAuthChanged);
    super.dispose();
  }

  String get _storagePrefix {
    final user = _authManager.user;
    if (user == null) return 'default';
    return '${user.isGuest ? 'guest' : 'user'}_${user.id}';
  }

  void _onAuthChanged() {
    final user = _authManager.user;
    final userId = user?.id;
    if (userId != _lastUserId) {
      _lastUserId = userId;
      _loadStats();
    }
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

  int _hintsRemaining = 3;
  int get hintsRemaining => _hintsRemaining;

  bool _usedHint = false;
  bool get usedHint => _usedHint;

  Set<int> _eliminatedOptions = {};
  Set<int> get eliminatedOptions => _eliminatedOptions;

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

  int questionCountForCategory(QuestionCategory category) {
    return _allQuestions.where((q) => q.category == category).length;
  }

  Future<void> loadQuestions() async {
    _allQuestions = await _getQuestions.execute();
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
    _hintsRemaining = 3;
    _usedHint = false;
    _eliminatedOptions = {};
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
      var reward = _questions[_currentIndex].stampReward;
      if (_usedHint) reward = max(reward ~/ 2, 1);
      final doubleXpActive = _powerUpProvider?.hasEffect(PowerUpType.doubleXp) ?? false;
      if (doubleXpActive) {
        reward *= 2;
        _powerUpProvider!.consumeEffect(PowerUpType.doubleXp);
      }
      _stamps += reward;
      _currentStreak++;
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
      }
      _totalCorrect++;
      _animateStamp = true;
      _saveStats();
    } else {
      final skipActive = _powerUpProvider?.hasEffect(PowerUpType.skipQuestion) ?? false;
      if (skipActive) {
        _powerUpProvider!.consumeEffect(PowerUpType.skipQuestion);
      } else {
        _currentStreak = 0;
      }
      _animateStamp = false;
    }

    notifyListeners();
  }

  void useHint() {
    if (_hintsRemaining <= 0 || _answered) return;
    _hintsRemaining--;
    _usedHint = true;

    final correctIdx = _questions[_currentIndex].correctIndex;
    final wrongIndices = List.generate(_questions[_currentIndex].options.length, (i) => i)
        .where((i) => i != correctIdx)
        .toList();
    wrongIndices.shuffle();
    _eliminatedOptions = wrongIndices.take(min(2, wrongIndices.length)).toSet();

    notifyListeners();
  }

  void nextQuestion() {
    _usedHint = false;
    _eliminatedOptions = {};
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

  void deductStamps(int amount) {
    _stamps = max(_stamps - amount, 0);
    _saveStats();
    notifyListeners();
  }

  void addHint() {
    _hintsRemaining++;
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
    _hintsRemaining = 3;
    _usedHint = false;
    _eliminatedOptions = {};
    await _saveStats();
    await loadQuestions();
    notifyListeners();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    _bestStreak = prefs.getInt('${_storagePrefix}_bestStreak') ?? 0;
    _totalCorrect = prefs.getInt('${_storagePrefix}_totalCorrect') ?? 0;
    _totalAnswered = prefs.getInt('${_storagePrefix}_totalAnswered') ?? 0;
    _stamps = prefs.getInt('${_storagePrefix}_stamps') ?? 0;
    notifyListeners();
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_storagePrefix}_stamps', _stamps);
    await prefs.setInt('${_storagePrefix}_bestStreak', _bestStreak);
    await prefs.setInt('${_storagePrefix}_totalCorrect', _totalCorrect);
    await prefs.setInt('${_storagePrefix}_totalAnswered', _totalAnswered);
  }
}
