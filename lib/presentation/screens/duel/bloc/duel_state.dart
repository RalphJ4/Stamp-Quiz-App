import 'package:equatable/equatable.dart';
import '../../../../domain/entities/duel.dart' as domain;

class DuelBlocState extends Equatable {
  final domain.DuelState? duel;
  final String? currentDuelId;
  final bool loading;
  final String? error;
  final int remainingSeconds;

  const DuelBlocState({
    this.duel,
    this.currentDuelId,
    this.loading = false,
    this.error,
    this.remainingSeconds = 60,
  });

  DuelBlocState copyWith({
    domain.DuelState? duel,
    String? currentDuelId,
    bool? loading,
    String? error,
    int? remainingSeconds,
    bool clearError = false,
  }) {
    return DuelBlocState(
      duel: duel ?? this.duel,
      currentDuelId: currentDuelId ?? this.currentDuelId,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  @override
  List<Object?> get props => [duel, currentDuelId, loading, error, remainingSeconds];
}
