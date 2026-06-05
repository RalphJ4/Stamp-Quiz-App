import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/leaderboard_period.dart';
import '../../data/datasources/leaderboard_datasource.dart';
import '../../services/auth_mode_manager.dart';
import 'quiz_provider.dart';

class LeaderboardProvider extends ChangeNotifier {
  final AuthModeManager _authManager;
  final QuizProvider _quizProvider;
  final LeaderboardDatasource _datasource = LeaderboardDatasource();
  final Logger _log = Logger();

  final Map<LeaderboardPeriod, List<LeaderboardEntry>> _entries = {};
  final Map<LeaderboardPeriod, bool> _loading = {};
  final Map<LeaderboardPeriod, int> _userRanks = {};
  LeaderboardPeriod _selectedTab = LeaderboardPeriod.allTime;
  LeaderboardEntry? _currentUserEntry;

  int _lastSyncedStamps = -1;
  Timer? _refreshDebounce;

  LeaderboardProvider(this._authManager, this._quizProvider) {
    _quizProvider.addListener(_onQuizStampsChanged);
  }

  List<LeaderboardEntry> get currentEntries => _entries[_selectedTab] ?? [];
  LeaderboardPeriod get selectedTab => _selectedTab;
  LeaderboardEntry? get currentUserEntry => _currentUserEntry;
  int get currentUserRank => _userRanks[_selectedTab] ?? 0;

  bool isLoading(LeaderboardPeriod period) => _loading[period] ?? false;

  @override
  void dispose() {
    _refreshDebounce?.cancel();
    _quizProvider.removeListener(_onQuizStampsChanged);
    super.dispose();
  }

  void _onQuizStampsChanged() {
    if (_authManager.isGuest) return;
    final currentStamps = _quizProvider.stamps;
    if (currentStamps == _lastSyncedStamps) return;
    _lastSyncedStamps = currentStamps;
    _pushXp();
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(seconds: 2), _refreshAll);
  }

  Future<void> _pushXp() async {
    if (_authManager.isGuest) return;
    final uid = _authManager.user?.id;
    if (uid == null) return;
    try {
      final name = _authManager.user?.name ?? _authManager.user?.email ?? 'Anonymous';
      final totalXp = _quizProvider.stamps;
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

  Future<void> _refreshAll() async {
    if (_authManager.isGuest) return;
    final uid = _authManager.user?.id;
    if (uid == null) return;
    try {
      _currentUserEntry = await _datasource.getUserEntry(uid);
      await fetchCurrentUserRank();
      if (_entries[_selectedTab] != null) {
        await fetchPeriod(_selectedTab);
      }
    } catch (e) {
      _log.e('Failed to refresh leaderboard: $e');
    }
  }

  void selectTab(LeaderboardPeriod period) {
    if (_selectedTab == period) return;
    _selectedTab = period;
    notifyListeners();

    if (_entries[period] == null) {
      fetchPeriod(period);
    }
  }

  Future<void> fetchPeriod(LeaderboardPeriod period) async {
    _loading[period] = true;
    notifyListeners();

    try {
      _entries[period] = await _datasource.fetchLeaderboard(period);
      _loading[period] = false;
      notifyListeners();
    } catch (e) {
      _log.e('Failed to fetch leaderboard ($period): $e');
      _loading[period] = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentUserRank() async {
    final uid = _authManager.user?.id;
    if (uid == null) return;

    for (final period in LeaderboardPeriod.values) {
      _userRanks[period] = await _datasource.getUserRank(uid, period);
    }
    notifyListeners();
  }

  Future<void> syncCurrentUser() async {
    await _pushXp();
    await _refreshAll();
  }

  void selectTabByIndex(int index) {
    selectTab(LeaderboardPeriod.values[index]);
  }


}
