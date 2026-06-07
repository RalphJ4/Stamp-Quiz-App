import '../../../../domain/entities/duel.dart' as domain;

sealed class DuelEvent {}

final class DuelCreate extends DuelEvent {}

final class DuelJoin extends DuelEvent {
  final String duelId;
  DuelJoin({required this.duelId});
}

final class DuelSubmitAnswer extends DuelEvent {
  final bool isCorrect;
  DuelSubmitAnswer({required this.isCorrect});
}

final class DuelReset extends DuelEvent {}

final class DuelTimerTick extends DuelEvent {}

final class DuelUpdated extends DuelEvent {
  final domain.DuelState? duel;
  DuelUpdated({this.duel});
}
