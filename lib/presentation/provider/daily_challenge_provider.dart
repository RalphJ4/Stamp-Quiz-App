import 'package:flutter/foundation.dart';
import '../../services/auth_mode_manager.dart';
import '../../data/datasources/daily_challenge_datasource.dart';
import '../../domain/entities/daily_challenge.dart';
import '../../domain/entities/question.dart';

class DailyChallengeProvider extends ChangeNotifier {
  final AuthModeManager _authManager;
  final DailyChallengeDatasource _datasource = DailyChallengeDatasource();
  String? _lastUserId;

  DailyChallenge? _challenge;
  bool _loading = true;
  bool _completed = false;
  int _currentIndex = 0;
  bool _answered = false;
  int? _selectedOption;
  int _correctCount = 0;
  int _dailyStreak = 0;

  DailyChallengeProvider(this._authManager) {
    _authManager.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authManager.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    final user = _authManager.user;
    final userId = user?.id;
    if (userId != _lastUserId && !_loading) {
      _lastUserId = userId;
      loadToday();
    }
  }

  DailyChallenge? get challenge => _challenge;
  bool get loading => _loading;
  bool get completed => _completed;
  int get currentIndex => _currentIndex;
  bool get answered => _answered;
  int? get selectedOption => _selectedOption;
  int get correctCount => _correctCount;
  int get dailyStreak => _dailyStreak;
  bool get isFinished => _currentIndex >= (_challenge?.questions.length ?? 0);

  Question? get currentQuestion {
    if (_challenge == null || _currentIndex >= _challenge!.questions.length) return null;
    return _challenge!.questions[_currentIndex];
  }

  Future<void> loadToday() async {
    _loading = true;
    notifyListeners();

    await _datasource.checkAndResetStreak();
    _dailyStreak = await _datasource.getDailyStreak();

    final user = _authManager.user;
    final uid = user?.id;
    _lastUserId = uid;

    _challenge = await _datasource.getOrCreateToday();

    if (uid != null && _challenge != null) {
      _completed = _challenge!.isCompletedBy(uid);
    }

    _currentIndex = 0;
    _answered = false;
    _selectedOption = null;
    _correctCount = 0;
    _loading = false;
    notifyListeners();
  }

  void selectOption(int index) {
    if (_answered || _completed || _challenge == null) return;
    _selectedOption = index;
    _answered = true;

    if (_challenge!.questions[_currentIndex].correctIndex == index) {
      _correctCount++;
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < (_challenge?.questions.length ?? 0) - 1) {
      _currentIndex++;
      _answered = false;
      _selectedOption = null;
      notifyListeners();
    } else {
      _submitCompletion();
    }
  }

  Future<void> _submitCompletion() async {
    final user = _authManager.user;
    final uid = user?.id;
    if (uid == null || _challenge == null) return;

    await _datasource.markCompleted(uid);

    _completed = true;
    _dailyStreak++;
    await _datasource.updateDailyStreak(_dailyStreak);

    notifyListeners();
  }

  String get timeUntilReset {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
