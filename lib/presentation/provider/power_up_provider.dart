import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/power_up.dart';
import '../../data/datasources/power_up_shop_datasource.dart';
import '../../services/auth_mode_manager.dart';
import 'quiz_provider.dart';

class PowerUpProvider extends ChangeNotifier {
  final AuthModeManager _authManager;
  final QuizProvider _quizProvider;
  final PowerUpShopDatasource _datasource = PowerUpShopDatasource();
  final Logger _log = Logger();

  Map<PowerUpType, int> _inventory = {};
  Map<PowerUpType, int> _activeEffects = {};

  PowerUpProvider(this._authManager, this._quizProvider) {
    _authManager.addListener(_onAuthChanged);
    _quizProvider.attachPowerUpProvider(this);
  }

  @override
  void dispose() {
    _authManager.removeListener(_onAuthChanged);
    super.dispose();
  }

  Map<PowerUpType, int> get inventory => Map.unmodifiable(_inventory);
  Map<PowerUpType, int> get activeEffects => Map.unmodifiable(_activeEffects);

  bool get hasActiveEffects => _activeEffects.isNotEmpty;

  int countOf(PowerUpType type) => _inventory[type] ?? 0;
  int activeCount(PowerUpType type) => _activeEffects[type] ?? 0;

  void _onAuthChanged() {
    final uid = _authManager.user?.id;
    if (uid != null) {
      fetchInventory().catchError((e) {
        _log.e('Failed to fetch inventory: $e');
      });
    } else {
      _inventory = {};
      _activeEffects = {};
      notifyListeners();
    }
  }

  Future<void> fetchInventory() async {
    final uid = _authManager.user?.id;
    if (uid == null) {
      _inventory = {};
      _activeEffects = {};
      notifyListeners();
      return;
    }

    _inventory = await _datasource.fetchInventory(uid);
    notifyListeners();
  }

  Future<String?> purchasePowerUp(PowerUpType type) async {
    final uid = _authManager.user?.id;
    if (uid == null) return 'Not signed in';

    final cost = type.cost;
    if (_quizProvider.stamps < cost) return 'Not enough stamps';

    final error = await _datasource.purchase(uid, type, cost);
    if (error != null) return error;

    _quizProvider.deductStamps(cost);

    _inventory[type] = (_inventory[type] ?? 0) + 1;
    notifyListeners();
    _log.i('Purchased ${type.label} for $cost XP');
    return null;
  }

  String? activatePowerUp(PowerUpType type) {
    final count = _inventory[type] ?? 0;
    if (count <= 0) return 'None in inventory';

    final uid = _authManager.user?.id;
    if (uid == null) return 'Not signed in';

    _inventory[type] = count - 1;
    if (_inventory[type]! <= 0) _inventory.remove(type);

    _datasource.decrementInventory(uid, type).catchError((e) {
      _log.e('Failed to decrement inventory: $e');
    });

    switch (type) {
      case PowerUpType.extraHint:
        _quizProvider.addHint();
        break;
      case PowerUpType.doubleXp:
        _activeEffects[PowerUpType.doubleXp] =
            (_activeEffects[PowerUpType.doubleXp] ?? 0) + 1;
        break;
      case PowerUpType.skipQuestion:
        _activeEffects[PowerUpType.skipQuestion] =
            (_activeEffects[PowerUpType.skipQuestion] ?? 0) + 1;
        break;
      case PowerUpType.timeFreeze:
        _activeEffects[PowerUpType.timeFreeze] =
            (_activeEffects[PowerUpType.timeFreeze] ?? 0) + 1;
        break;
    }

    notifyListeners();
    _log.i('Activated ${type.label}');
    return null;
  }

  void consumeEffect(PowerUpType type) {
    final current = _activeEffects[type] ?? 0;
    if (current <= 1) {
      _activeEffects.remove(type);
    } else {
      _activeEffects[type] = current - 1;
    }
    notifyListeners();
  }

  bool hasEffect(PowerUpType type) => (_activeEffects[type] ?? 0) > 0;
}
