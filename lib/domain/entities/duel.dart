import 'question.dart';

enum DuelStatus { waiting, active, complete }

class DuelState {
  final String duelId;
  final String hostUid;
  final String? guestUid;
  final DuelStatus status;
  final int hostScore;
  final int guestScore;
  final int hostProgress;
  final int guestProgress;
  final List<Question> questions;
  final DateTime startedAt;
  final String? winnerUid;

  const DuelState({
    required this.duelId,
    required this.hostUid,
    this.guestUid,
    required this.status,
    this.hostScore = 0,
    this.guestScore = 0,
    this.hostProgress = 0,
    this.guestProgress = 0,
    required this.questions,
    required this.startedAt,
    this.winnerUid,
  });

  bool get isHost => true;
  bool get isWaiting => status == DuelStatus.waiting;
  bool get isActive => status == DuelStatus.active;
  bool get isComplete => status == DuelStatus.complete;

  DuelState copyWith({
    String? duelId,
    String? hostUid,
    String? guestUid,
    DuelStatus? status,
    int? hostScore,
    int? guestScore,
    int? hostProgress,
    int? guestProgress,
    List<Question>? questions,
    DateTime? startedAt,
    String? winnerUid,
  }) {
    return DuelState(
      duelId: duelId ?? this.duelId,
      hostUid: hostUid ?? this.hostUid,
      guestUid: guestUid ?? this.guestUid,
      status: status ?? this.status,
      hostScore: hostScore ?? this.hostScore,
      guestScore: guestScore ?? this.guestScore,
      hostProgress: hostProgress ?? this.hostProgress,
      guestProgress: guestProgress ?? this.guestProgress,
      questions: questions ?? this.questions,
      startedAt: startedAt ?? this.startedAt,
      winnerUid: winnerUid ?? this.winnerUid,
    );
  }
}
