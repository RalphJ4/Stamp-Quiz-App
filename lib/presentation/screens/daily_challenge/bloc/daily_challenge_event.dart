sealed class DailyChallengeEvent {}

final class DailyChallengeLoadToday extends DailyChallengeEvent {}

final class DailyChallengeSelectOption extends DailyChallengeEvent {
  final int index;
  DailyChallengeSelectOption({required this.index});
}

final class DailyChallengeNextQuestion extends DailyChallengeEvent {}
