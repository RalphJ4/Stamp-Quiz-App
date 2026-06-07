import 'package:equatable/equatable.dart';
import '../../../../domain/entities/leaderboard_entry.dart';
import '../../../../domain/entities/leaderboard_period.dart';

class LeaderboardState extends Equatable {
  final Map<LeaderboardPeriod, List<LeaderboardEntry>> entries;
  final Map<LeaderboardPeriod, bool> loading;
  final Map<LeaderboardPeriod, int> userRanks;
  final LeaderboardPeriod selectedTab;
  final LeaderboardEntry? currentUserEntry;

  const LeaderboardState({
    this.entries = const {},
    this.loading = const {},
    this.userRanks = const {},
    this.selectedTab = LeaderboardPeriod.allTime,
    this.currentUserEntry,
  });

  List<LeaderboardEntry> get currentEntries => entries[selectedTab] ?? [];
  int get currentUserRank => userRanks[selectedTab] ?? 0;
  bool isLoading(LeaderboardPeriod period) => loading[period] ?? false;

  LeaderboardState copyWith({
    Map<LeaderboardPeriod, List<LeaderboardEntry>>? entries,
    Map<LeaderboardPeriod, bool>? loading,
    Map<LeaderboardPeriod, int>? userRanks,
    LeaderboardPeriod? selectedTab,
    LeaderboardEntry? currentUserEntry,
    bool clearCurrentUserEntry = false,
  }) {
    return LeaderboardState(
      entries: entries ?? this.entries,
      loading: loading ?? this.loading,
      userRanks: userRanks ?? this.userRanks,
      selectedTab: selectedTab ?? this.selectedTab,
      currentUserEntry: clearCurrentUserEntry ? null : (currentUserEntry ?? this.currentUserEntry),
    );
  }

  @override
  List<Object?> get props => [entries, loading, userRanks, selectedTab, currentUserEntry];
}
