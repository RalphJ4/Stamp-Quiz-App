import '../../../../domain/entities/power_up.dart';

sealed class PowerUpEvent {}

final class PowerUpFetchInventory extends PowerUpEvent {}

final class PowerUpPurchase extends PowerUpEvent {
  final PowerUpType type;
  PowerUpPurchase({required this.type});
}

final class PowerUpActivate extends PowerUpEvent {
  final PowerUpType type;
  PowerUpActivate({required this.type});
}

final class PowerUpConsumeEffect extends PowerUpEvent {
  final PowerUpType type;
  PowerUpConsumeEffect({required this.type});
}
