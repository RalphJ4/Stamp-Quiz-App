// ignore_for_file: invalid_use_of_visible_for_testing_member

export 'daily_challenge_event.dart';
export 'daily_challenge_state.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../../data/datasources/daily_challenge_datasource.dart';
import 'daily_challenge_event.dart';
import 'daily_challenge_state.dart';

class DailyChallengeBloc extends Bloc<DailyChallengeEvent, DailyChallengeState> {
  final AuthBloc _authBloc;
  final DailyChallengeDatasource _datasource = DailyChallengeDatasource();
  Timer? _countdownTimer;
  StreamSubscription<AuthState>? _authSubscription;

  DailyChallengeBloc(this._authBloc) : super(const DailyChallengeState()) {
    on<DailyChallengeLoadToday>(_onLoadToday);
    on<DailyChallengeSelectOption>(_onSelectOption);
    on<DailyChallengeNextQuestion>(_onNextQuestion);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState.initialized) {
        add(DailyChallengeLoadToday());
      }
    });
  }

  void _tick() {
    // Re-emit state so timeUntilReset (which uses DateTime.now()) recalculates
    emit(state.copyWith());
  }

  void _onLoadToday(DailyChallengeLoadToday event, Emitter<DailyChallengeState> emit) async {
    emit(state.copyWith(loading: true));

    await _datasource.checkAndResetStreak();
    final dailyStreak = await _datasource.getDailyStreak();
    final uid = _authBloc.state.user?.id;
    final challenge = await _datasource.getOrCreateToday();

    var completed = false;
    if (uid != null) {
      completed = challenge.isCompletedBy(uid);
    }

    emit(state.copyWith(
      challenge: challenge,
      loading: false,
      completed: completed,
      currentIndex: 0,
      answered: false,
      selectedOption: null,
      correctCount: 0,
      dailyStreak: dailyStreak,
    ));
  }

  void _onSelectOption(DailyChallengeSelectOption event, Emitter<DailyChallengeState> emit) {
    if (state.answered || state.completed || state.challenge == null) return;
    final isCorrect = state.challenge!.questions[state.currentIndex].correctIndex == event.index;
    final newCorrectCount = isCorrect ? state.correctCount + 1 : state.correctCount;

    emit(state.copyWith(
      selectedOption: event.index,
      answered: true,
      correctCount: newCorrectCount,
    ));
  }

  void _onNextQuestion(DailyChallengeNextQuestion event, Emitter<DailyChallengeState> emit) async {
    if (state.currentIndex < (state.challenge?.questions.length ?? 0) - 1) {
      emit(state.copyWith(
        currentIndex: state.currentIndex + 1,
        answered: false,
        selectedOption: null,
      ));
    } else {
      await _submitCompletion(emit);
    }
  }

  Future<void> _submitCompletion(Emitter<DailyChallengeState> emit) async {
    final uid = _authBloc.state.user?.id;
    if (uid == null || state.challenge == null) return;

    await _datasource.markCompleted(uid);
    final newDailyStreak = state.dailyStreak + 1;
    await _datasource.updateDailyStreak(newDailyStreak);

    emit(state.copyWith(
      completed: true,
      dailyStreak: newDailyStreak,
    ));
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
