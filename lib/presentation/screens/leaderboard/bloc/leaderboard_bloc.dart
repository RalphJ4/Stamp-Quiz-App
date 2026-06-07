import 'dart:async';

export 'leaderboard_event.dart';
export 'leaderboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../domain/entities/leaderboard_entry.dart';
import '../../../../domain/entities/leaderboard_period.dart';
import '../../../../data/datasources/leaderboard_datasource.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../quiz/bloc/quiz_bloc.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final AuthBloc _authBloc;
  final QuizBloc _quizBloc;
  final LeaderboardDatasource _datasource = LeaderboardDatasource();
  final Logger _log = Logger();

  int _lastSyncedStamps = -1;
  Timer? _refreshDebounce;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<QuizState>? _quizSubscription;

  /// Forces a full leaderboard sync regardless of [_lastSyncedStamps].
  void forceSync() {
    _lastSyncedStamps = -1;
    add(LeaderboardCheckAndSync());
  }

  LeaderboardBloc(this._authBloc, this._quizBloc) : super(const LeaderboardState()) {
    on<LeaderboardFetchPeriod>(_onFetchPeriod);
    on<LeaderboardSelectTab>(_onSelectTab);
    on<LeaderboardSyncCurrentUser>(_onSyncCurrentUser);
    on<LeaderboardFetchCurrentUserRank>(_onFetchCurrentUserRank);
    on<LeaderboardCheckAndSync>(_onCheckAndSync);

    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState.initialized) {
        add(LeaderboardSyncCurrentUser());
      }
    });

    _quizSubscription = _quizBloc.stream.listen((quizState) {
      add(LeaderboardCheckAndSync());
    });
  }

  @override
  Future<void> close() {
    _refreshDebounce?.cancel();
    _authSubscription?.cancel();
    _quizSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckAndSync(LeaderboardCheckAndSync event, Emitter<LeaderboardState> emit) async {
    if (_authBloc.state.isGuest) return;
    final currentStamps = _quizBloc.state.stamps;
    if (currentStamps == _lastSyncedStamps) return;
    _lastSyncedStamps = currentStamps;
    await _pushXp();
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(seconds: 2), () => add(LeaderboardSyncCurrentUser()));
  }

  Future<void> _pushXp() async {
    if (_authBloc.state.isGuest) return;
    final uid = _authBloc.state.user?.id;
    if (uid == null) return;
    try {
      final name = _authBloc.state.user?.name ?? _authBloc.state.user?.email ?? 'Anonymous';
      final totalXp = _quizBloc.state.stamps;
      await _datasource.syncXp(
        uid,
        allTimeXp: totalXp,
        weeklyXp: totalXp,
        monthlyXp: totalXp,
        displayName: name,
      );
    } catch (e) {
      _log.e('Failed to push XP: $e');
    }
  }

  void _onSyncCurrentUser(LeaderboardSyncCurrentUser event, Emitter<LeaderboardState> emit) async {
    if (_authBloc.state.isGuest) return;
    final uid = _authBloc.state.user?.id;
    if (uid == null) return;
    try {
      final currentUserEntry = await _datasource.getUserEntry(uid);
      emit(state.copyWith(currentUserEntry: currentUserEntry));
      add(LeaderboardFetchCurrentUserRank());
      for (final period in state.entries.keys) {
        add(LeaderboardFetchPeriod(period: period));
      }
    } catch (e) {
      _log.e('Failed to refresh leaderboard: $e');
    }
  }

  void _onSelectTab(LeaderboardSelectTab event, Emitter<LeaderboardState> emit) {
    if (state.selectedTab == event.period) return;
    emit(state.copyWith(selectedTab: event.period));

    if (state.entries[event.period] == null) {
      add(LeaderboardFetchPeriod(period: event.period));
    }
  }

  void _onFetchPeriod(LeaderboardFetchPeriod event, Emitter<LeaderboardState> emit) async {
    final newLoading = Map<LeaderboardPeriod, bool>.from(state.loading);
    newLoading[event.period] = true;
    emit(state.copyWith(loading: newLoading));

    try {
      final entries = await _datasource.fetchLeaderboard(event.period);
      final newEntries = Map<LeaderboardPeriod, List<LeaderboardEntry>>.from(state.entries);
      newEntries[event.period] = entries;
      final newLoading2 = Map<LeaderboardPeriod, bool>.from(newLoading);
      newLoading2[event.period] = false;
      emit(state.copyWith(entries: newEntries, loading: newLoading2));
    } catch (e) {
      _log.e('Failed to fetch leaderboard (${event.period}): $e');
      final newLoading2 = Map<LeaderboardPeriod, bool>.from(newLoading);
      newLoading2[event.period] = false;
      emit(state.copyWith(loading: newLoading2));
    }
  }

  void _onFetchCurrentUserRank(LeaderboardFetchCurrentUserRank event, Emitter<LeaderboardState> emit) async {
    final uid = _authBloc.state.user?.id;
    if (uid == null) return;

    final newUserRanks = Map<LeaderboardPeriod, int>.from(state.userRanks);
    for (final period in LeaderboardPeriod.values) {
      newUserRanks[period] = await _datasource.getUserRank(uid, period);
    }
    emit(state.copyWith(userRanks: newUserRanks));
  }
}
