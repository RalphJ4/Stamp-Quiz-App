import 'package:equatable/equatable.dart';
import '../../../../domain/entities/power_up.dart';

class PowerUpState extends Equatable {
  final Map<PowerUpType, int> inventory;
  final Map<PowerUpType, int> activeEffects;

  const PowerUpState({
    this.inventory = const {},
    this.activeEffects = const {},
  });

  bool get hasActiveEffects => activeEffects.isNotEmpty;
  int countOf(PowerUpType type) => inventory[type] ?? 0;
  int activeCount(PowerUpType type) => activeEffects[type] ?? 0;
  bool hasEffect(PowerUpType type) => (activeEffects[type] ?? 0) > 0;

  PowerUpState copyWith({
    Map<PowerUpType, int>? inventory,
    Map<PowerUpType, int>? activeEffects,
  }) {
    return PowerUpState(
      inventory: inventory ?? this.inventory,
      activeEffects: activeEffects ?? this.activeEffects,
    );
  }

  @override
  List<Object?> get props => [inventory, activeEffects];
}
