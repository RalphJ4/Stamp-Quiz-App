// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';

export 'duel_event.dart';
export 'duel_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../domain/entities/duel.dart' as domain;
import '../../../../data/datasources/duel_datasource.dart';
import '../../../../data/datasources/local_question_datasource.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../quiz/bloc/quiz_bloc.dart';
import 'duel_event.dart';
import 'duel_state.dart';

class DuelBloc extends Bloc<DuelEvent, DuelBlocState> {
  final AuthBloc _authBloc;
  final QuizBloc _quizBloc;
  final DuelDatasource _datasource = DuelDatasource();
  final LocalQuestionDataSource _local = LocalQuestionDataSource();
  final Logger _log = Logger();

  StreamSubscription<domain.DuelState?>? _subscription;
  Timer? _countdownTimer;
  Timer? _cleanupTimer;
  int? _pendingXpAward;

  DuelBloc(this._authBloc, this._quizBloc) : super(const DuelBlocState()) {
    on<DuelCreate>(_onCreate);
    on<DuelJoin>(_onJoin);
    on<DuelSubmitAnswer>(_onSubmitAnswer);
    on<DuelReset>(_onReset);
    on<DuelTimerTick>(_onTimerTick);
    on<DuelUpdated>(_onDuelUpdated);
  }

  bool get isHost {
    final uid = _authBloc.state.user?.id;
    if (uid == null || state.duel == null) return false;
    return state.duel!.hostUid == uid;
  }

  String? get opponentUid {
    final uid = _authBloc.state.user?.id;
    if (uid == null || state.duel == null) return null;
    return state.duel!.hostUid == uid ? state.duel!.guestUid : state.duel!.hostUid;
  }

  int get myScore {
    final uid = _authBloc.state.user?.id;
    if (uid == null || state.duel == null) return 0;
    return state.duel!.hostUid == uid ? state.duel!.hostScore : state.duel!.guestScore;
  }

  int get opponentScore {
    final uid = _authBloc.state.user?.id;
    if (uid == null || state.duel == null) return 0;
    return state.duel!.hostUid == uid ? state.duel!.guestScore : state.duel!.hostScore;
  }

  int get myProgress {
    final uid = _authBloc.state.user?.id;
    if (uid == null || state.duel == null) return 0;
    return state.duel!.hostUid == uid ? state.duel!.hostProgress : state.duel!.guestProgress;
  }

  int get opponentProgress {
    final uid = _authBloc.state.user?.id;
    if (uid == null || state.duel == null) return 0;
    return state.duel!.hostUid == uid ? state.duel!.guestProgress : state.duel!.hostProgress;
  }

  void _onCreate(DuelCreate event, Emitter<DuelBlocState> emit) async {
    final uid = _authBloc.state.user?.id;
    if (uid == null) return;

    emit(state.copyWith(loading: true, clearError: true));

    try {
      final allQuestions = await _local.getLocalQuestions();
      allQuestions.shuffle();
      final questions = allQuestions.take(5).toList();

      final duelId = await _datasource.createDuel(uid, questions);
      emit(state.copyWith(currentDuelId: duelId, loading: false));
      _listenToDuel(duelId);

      _log.i('Duel created: $duelId');
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  void _onJoin(DuelJoin event, Emitter<DuelBlocState> emit) async {
    final uid = _authBloc.state.user?.id;
    if (uid == null) return;

    emit(state.copyWith(loading: true, clearError: true));

    try {
      await _datasource.joinDuel(event.duelId, uid);
      emit(state.copyWith(currentDuelId: event.duelId, loading: false));
      _listenToDuel(event.duelId);
      _log.i('Joined duel: ${event.duelId}');
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  void _listenToDuel(String duelId) {
    _subscription?.cancel();
    _subscription = _datasource.streamDuel(duelId).listen((snap) {
      add(DuelUpdated(duel: snap));
    });
  }

  void _onDuelUpdated(DuelUpdated event, Emitter<DuelBlocState> emit) {
    if (event.duel == null) {
      _log.i('Duel document deleted, cleaning up');
      _cleanupTimer?.cancel();
      _countdownTimer?.cancel();
      emit(state.copyWith(duel: null, currentDuelId: null, error: 'Duel ended'));
      return;
    }

    if (event.duel!.status == domain.DuelStatus.complete && _pendingXpAward == null) {
      final uid = _authBloc.state.user?.id;
      if (uid != null) {
        _pendingXpAward = event.duel!.winnerUid == uid ? 50 : 20;
      }
    }

    final wasActive = state.duel?.status == domain.DuelStatus.active;
    emit(state.copyWith(duel: event.duel, loading: false));

    if (event.duel!.status == domain.DuelStatus.active && !wasActive) {
      _startCountdown();
    }
    if (event.duel!.status == domain.DuelStatus.active && wasActive && _countdownTimer == null) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    emit(state.copyWith(remainingSeconds: 60));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(DuelTimerTick());
    });
  }

  void _onTimerTick(DuelTimerTick event, Emitter<DuelBlocState> emit) {
    final newRemaining = state.remainingSeconds - 1;
    emit(state.copyWith(remainingSeconds: newRemaining));

    if (newRemaining <= 0) {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      _timeUp();
    }
  }

  Future<void> _timeUp() async {
    _log.i('Duel timer expired');
    final id = state.currentDuelId;
    if (id == null) return;

    String? winner;
    if (state.duel != null) {
      if (state.duel!.hostScore > state.duel!.guestScore) {
        winner = state.duel!.hostUid;
      } else if (state.duel!.guestScore > state.duel!.hostScore) {
        winner = state.duel!.guestUid;
      }
    }

    try {
      await _datasource.finishDuel(id, winner);
      _log.i('Duel auto-finished due to timeout');
    } catch (e) {
      _log.e('Failed to auto-finish duel: $e');
    }

    final myUid = _authBloc.state.user?.id;
    _pendingXpAward = myUid != null ? (winner == myUid ? 50 : 20) : null;

    _cleanupTimer?.cancel();
    _cleanupTimer = Timer(const Duration(seconds: 3), () => _deleteCurrentDuel());
  }

  Future<void> _deleteCurrentDuel() async {
    final id = state.currentDuelId;
    if (id == null) return;
    try {
      await _datasource.deleteDuel(id);
      _log.i('Duel document deleted: $id');
    } catch (e) {
      _log.e('Failed to delete duel document: $e');
    }
  }

  void _onSubmitAnswer(DuelSubmitAnswer event, Emitter<DuelBlocState> emit) async {
    final uid = _authBloc.state.user?.id;
    if (uid == null || state.currentDuelId == null) return;

    final newProgress = myProgress + 1;
    await _datasource.submitAnswer(state.currentDuelId!, uid, event.isCorrect, newProgress);

    if (newProgress >= 5) {
      final updated = await _datasource.streamDuel(state.currentDuelId!).first;
      if (updated != null && updated.guestProgress >= 5 && updated.hostProgress >= 5) {
        final winner = updated.hostScore > updated.guestScore
            ? updated.hostUid
            : updated.guestScore > updated.hostScore
                ? updated.guestUid
                : null;
        await _datasource.finishDuel(state.currentDuelId!, winner);

        final myUid = _authBloc.state.user?.id;
        _pendingXpAward = myUid != null ? (winner == myUid ? 50 : 20) : null;

        _cleanupTimer?.cancel();
        _cleanupTimer = Timer(const Duration(seconds: 3), () => _deleteCurrentDuel());
      }
    }
  }

  void _onReset(DuelReset event, Emitter<DuelBlocState> emit) async {
    _pendingXpAward = null;
    await _deleteCurrentDuel();
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _subscription?.cancel();
    _subscription = null;
    emit(const DuelBlocState());
  }

  void awardXp() {
    if (_pendingXpAward == null) return;
    _quizBloc.add(QuizAwardStamps(amount: _pendingXpAward!));
    _pendingXpAward = null;
  }

  @override
  Future<void> close() {
    _pendingXpAward = null;
    _countdownTimer?.cancel();
    _cleanupTimer?.cancel();
    _subscription?.cancel();
    return super.close();
  }
}
