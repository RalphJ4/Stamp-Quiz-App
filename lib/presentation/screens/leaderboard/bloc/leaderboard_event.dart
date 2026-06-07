import '../../../../domain/entities/leaderboard_period.dart';

sealed class LeaderboardEvent {}

final class LeaderboardFetchPeriod extends LeaderboardEvent {
  final LeaderboardPeriod period;
  LeaderboardFetchPeriod({required this.period});
}

final class LeaderboardSelectTab extends LeaderboardEvent {
  final LeaderboardPeriod period;
  LeaderboardSelectTab({required this.period});
}

final class LeaderboardSyncCurrentUser extends LeaderboardEvent {}

final class LeaderboardFetchCurrentUserRank extends LeaderboardEvent {}

final class LeaderboardCheckAndSync extends LeaderboardEvent {}
