enum LeaderboardPeriod { allTime, weekly, monthly }

extension LeaderboardPeriodMeta on LeaderboardPeriod {
  String get label {
    switch (this) {
      case LeaderboardPeriod.allTime:
        return 'All-Time';
      case LeaderboardPeriod.weekly:
        return 'This Week';
      case LeaderboardPeriod.monthly:
        return 'This Month';
    }
  }

  String get firestoreField {
    switch (this) {
      case LeaderboardPeriod.allTime:
        return 'allTimeXp';
      case LeaderboardPeriod.weekly:
        return 'weeklyXp';
      case LeaderboardPeriod.monthly:
        return 'monthlyXp';
    }
  }
}
