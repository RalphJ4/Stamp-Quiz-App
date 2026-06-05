import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/duel.dart';
import '../../data/datasources/duel_datasource.dart';
import '../../data/datasources/local_question_datasource.dart';
import '../../services/auth_mode_manager.dart';

class DuelProvider extends ChangeNotifier {
  final AuthModeManager _authManager;
  final DuelDatasource _datasource = DuelDatasource();
  final LocalQuestionDataSource _local = LocalQuestionDataSource();
  final Logger _log = Logger();

  DuelState? _state;
  String? _currentDuelId;
  StreamSubscription<DuelState?>? _subscription;
  bool _loading = false;
  String? _error;

  int _remainingSeconds = 60;
  Timer? _countdownTimer;
  Timer? _cleanupTimer;

  DuelProvider(this._authManager);

  DuelState? get state => _state;
  bool get loading => _loading;
  String? get error => _error;
  String? get currentDuelId => _currentDuelId;
  int get remainingSeconds => _remainingSeconds;

  bool get isHost {
    final uid = _authManager.user?.id;
    if (uid == null || _state == null) return false;
    return _state!.hostUid == uid;
  }

  bool get isMyTurn {
    final uid = _authManager.user?.id;
    if (uid == null || _state == null) return false;
    return _state!.hostUid == uid
        ? _state!.hostProgress <= _state!.guestProgress
        : _state!.guestProgress <= _state!.hostProgress;
  }

  String? get opponentUid {
    final uid = _authManager.user?.id;
    if (uid == null || _state == null) return null;
    return _state!.hostUid == uid ? _state!.guestUid : _state!.hostUid;
  }

  int get myScore {
    final uid = _authManager.user?.id;
    if (uid == null || _state == null) return 0;
    return _state!.hostUid == uid ? _state!.hostScore : _state!.guestScore;
  }

  int get opponentScore {
    final uid = _authManager.user?.id;
    if (uid == null || _state == null) return 0;
    return _state!.hostUid == uid ? _state!.guestScore : _state!.hostScore;
  }

  int get myProgress {
    final uid = _authManager.user?.id;
    if (uid == null || _state == null) return 0;
    return _state!.hostUid == uid ? _state!.hostProgress : _state!.guestProgress;
  }

  int get opponentProgress {
    final uid = _authManager.user?.id;
    if (uid == null || _state == null) return 0;
    return _state!.hostUid == uid ? _state!.guestProgress : _state!.hostProgress;
  }

  Future<String?> createDuel() async {
    final uid = _authManager.user?.id;
    if (uid == null) return 'Sign in required';

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final allQuestions = await _local.getLocalQuestions();
      allQuestions.shuffle();
      final questions = allQuestions.take(5).toList();

      final duelId = await _datasource.createDuel(uid, questions);
      _currentDuelId = duelId;
      _listenToDuel(duelId);

      _log.i('Duel created: $duelId');
      return null;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return _error;
    }
  }

  Future<String?> joinDuel(String duelId) async {
    final uid = _authManager.user?.id;
    if (uid == null) return 'Sign in required';

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _datasource.joinDuel(duelId, uid);
      _currentDuelId = duelId;
      _listenToDuel(duelId);
      _log.i('Joined duel: $duelId');
      return null;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return _error;
    }
  }

  void _listenToDuel(String duelId) {
    _subscription?.cancel();
    _subscription = _datasource.streamDuel(duelId).listen((snap) {
      if (snap == null) {
        _error = 'Duel ended';
        _log.i('Duel document deleted, cleaning up');
        _cleanupTimer?.cancel();
        _countdownTimer?.cancel();
        _state = null;
        _currentDuelId = null;
        notifyListeners();
        return;
      }
      final wasActive = _state?.status == DuelStatus.active;
      _state = snap;
      _loading = false;
      notifyListeners();

      if (snap.status == DuelStatus.active && !wasActive) {
        _startCountdown();
      }
      if (snap.status == DuelStatus.active && wasActive && _countdownTimer == null) {
        _startCountdown();
      }
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _remainingSeconds = 60;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      notifyListeners();

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _countdownTimer = null;
        _timeUp();
      }
    });
  }

  Future<void> _timeUp() async {
    _log.i('Duel timer expired');
    final id = _currentDuelId;
    if (id == null) return;

    String? winner;
    if (_state != null) {
      if (_state!.hostScore > _state!.guestScore) {
        winner = _state!.hostUid;
      } else if (_state!.guestScore > _state!.hostScore) {
        winner = _state!.guestUid;
      }
    }

    try {
      await _datasource.finishDuel(id, winner);
      _log.i('Duel auto-finished due to timeout');
    } catch (e) {
      _log.e('Failed to auto-finish duel: $e');
    }

    _cleanupTimer?.cancel();
    _cleanupTimer = Timer(const Duration(seconds: 3), () => _deleteCurrentDuel());
  }

  Future<void> _deleteCurrentDuel() async {
    final id = _currentDuelId;
    if (id == null) return;
    try {
      await _datasource.deleteDuel(id);
      _log.i('Duel document deleted: $id');
    } catch (e) {
      _log.e('Failed to delete duel document: $e');
    }
  }

  Future<void> submitAnswer(bool isCorrect) async {
    final uid = _authManager.user?.id;
    if (uid == null || _currentDuelId == null) return;

    final newProgress = myProgress + 1;
    await _datasource.submitAnswer(_currentDuelId!, uid, isCorrect, newProgress);

    if (newProgress >= 5) {
      final updated = await _datasource.streamDuel(_currentDuelId!).first;
      if (updated != null && updated.guestProgress >= 5 && updated.hostProgress >= 5) {
        final winner = updated.hostScore > updated.guestScore
            ? updated.hostUid
            : updated.guestScore > updated.hostScore
                ? updated.guestUid
                : null;
        await _datasource.finishDuel(_currentDuelId!, winner);

        _cleanupTimer?.cancel();
        _cleanupTimer = Timer(const Duration(seconds: 3), () => _deleteCurrentDuel());
      }
    }
  }

  Future<void> reset() async {
    await _deleteCurrentDuel();
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _state = null;
    _currentDuelId = null;
    _loading = false;
    _error = null;
    _remainingSeconds = 60;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cleanupTimer?.cancel();
    _subscription?.cancel();
    _cleanupTimer = null;
    _countdownTimer = null;
    _subscription = null;
    super.dispose();
  }
}
