export 'power_up_event.dart';
export 'power_up_state.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../domain/entities/power_up.dart';
import '../../../../data/datasources/power_up_shop_datasource.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../quiz/bloc/quiz_bloc.dart';
import 'power_up_event.dart';
import 'power_up_state.dart';

class PowerUpBloc extends Bloc<PowerUpEvent, PowerUpState> {
  final AuthBloc _authBloc;
  final QuizBloc _quizBloc;
  final PowerUpShopDatasource _datasource = PowerUpShopDatasource();
  final Logger _log = Logger();
  StreamSubscription<AuthState>? _authSubscription;

  PowerUpBloc(this._authBloc, this._quizBloc) : super(const PowerUpState()) {
    on<PowerUpFetchInventory>(_onFetchInventory);
    on<PowerUpPurchase>(_onPurchase);
    on<PowerUpActivate>(_onActivate);
    on<PowerUpConsumeEffect>(_onConsumeEffect);

    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState.initialized) {
        add(PowerUpFetchInventory());
      }
    });
  }

  void _onFetchInventory(PowerUpFetchInventory event, Emitter<PowerUpState> emit) async {
    final uid = _authBloc.state.user?.id;
    if (uid == null) {
      emit(const PowerUpState());
      return;
    }
    final inventory = await _datasource.fetchInventory(uid);
    emit(state.copyWith(inventory: inventory));
  }

  void _onPurchase(PowerUpPurchase event, Emitter<PowerUpState> emit) async {
    final uid = _authBloc.state.user?.id;
    if (uid == null) return;

    final cost = event.type.cost;
    if (_quizBloc.state.stamps < cost) return;

    final error = await _datasource.purchase(uid, event.type, cost);
    if (error != null) return;

    _quizBloc.add(QuizDeductStamps(amount: cost));

    final newInventory = Map<PowerUpType, int>.from(state.inventory);
    newInventory[event.type] = (newInventory[event.type] ?? 0) + 1;
    emit(state.copyWith(inventory: newInventory));
    _log.i('Purchased ${event.type.label} for $cost XP');
  }

  void _onActivate(PowerUpActivate event, Emitter<PowerUpState> emit) {
    final count = state.inventory[event.type] ?? 0;
    if (count <= 0) return;

    final uid = _authBloc.state.user?.id;
    if (uid == null) return;

    final newInventory = Map<PowerUpType, int>.from(state.inventory);
    newInventory[event.type] = count - 1;
    if (newInventory[event.type]! <= 0) newInventory.remove(event.type);

    _datasource.decrementInventory(uid, event.type).catchError((e) {
      _log.e('Failed to decrement inventory: $e');
    });

    final newActiveEffects = Map<PowerUpType, int>.from(state.activeEffects);
    switch (event.type) {
      case PowerUpType.extraHint:
        _quizBloc.add(QuizAddHint());
        break;
      case PowerUpType.doubleXp:
        newActiveEffects[PowerUpType.doubleXp] = (newActiveEffects[PowerUpType.doubleXp] ?? 0) + 1;
        break;
      case PowerUpType.skipQuestion:
        newActiveEffects[PowerUpType.skipQuestion] = (newActiveEffects[PowerUpType.skipQuestion] ?? 0) + 1;
        break;
      case PowerUpType.timeFreeze:
        newActiveEffects[PowerUpType.timeFreeze] = (newActiveEffects[PowerUpType.timeFreeze] ?? 0) + 1;
        break;
    }

    emit(state.copyWith(
      inventory: newInventory,
      activeEffects: newActiveEffects,
    ));
    _log.i('Activated ${event.type.label}');
  }

  void _onConsumeEffect(PowerUpConsumeEffect event, Emitter<PowerUpState> emit) {
    final newActiveEffects = Map<PowerUpType, int>.from(state.activeEffects);
    final current = newActiveEffects[event.type] ?? 0;
    if (current <= 1) {
      newActiveEffects.remove(event.type);
    } else {
      newActiveEffects[event.type] = current - 1;
    }
    emit(state.copyWith(activeEffects: newActiveEffects));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
