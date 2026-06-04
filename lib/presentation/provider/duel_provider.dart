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

  DuelProvider(this._authManager);

  DuelState? get state => _state;
  bool get loading => _loading;
  String? get error => _error;
  String? get currentDuelId => _currentDuelId;

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
        _error = 'Duel not found';
        notifyListeners();
        return;
      }
      _state = snap;
      _loading = false;
      notifyListeners();
    });
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
        if (winner != null) {
          await _datasource.finishDuel(_currentDuelId!, winner);
        } else {
          await _datasource.finishDuel(_currentDuelId!, uid);
        }
      }
    }
  }

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _state = null;
    _currentDuelId = null;
    _loading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
