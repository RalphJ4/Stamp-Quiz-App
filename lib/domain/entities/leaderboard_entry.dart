import 'leaderboard_period.dart';

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final int allTimeXp;
  final int weeklyXp;
  final int monthlyXp;
  final int rank;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    this.allTimeXp = 0,
    this.weeklyXp = 0,
    this.monthlyXp = 0,
    this.rank = 0,
  });

  int xpForPeriod(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.allTime:
        return allTimeXp;
      case LeaderboardPeriod.weekly:
        return weeklyXp;
      case LeaderboardPeriod.monthly:
        return monthlyXp;
    }
  }
}
