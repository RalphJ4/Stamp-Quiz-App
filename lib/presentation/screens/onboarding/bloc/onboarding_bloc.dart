export 'onboarding_event.dart';
export 'onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  static const String _doneKey = 'onboarding_done';
  static const String _nameKey = 'player_name';
  static const String _colorKey = 'avatar_color';

  OnboardingBloc() : super(const OnboardingState()) {
    on<OnboardingLoadPreferences>(_onLoadPreferences);
    on<OnboardingNextStep>(_onNextStep);
    on<OnboardingSetPlayerName>(_onSetPlayerName);
    on<OnboardingSetAvatarColor>(_onSetAvatarColor);
    on<OnboardingTutorialSelect>(_onTutorialSelect);
    on<OnboardingComplete>(_onComplete);
  }

  void _onLoadPreferences(OnboardingLoadPreferences event, Emitter<OnboardingState> emit) async {
    emit(state.copyWith(loading: true));

    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_doneKey) ?? false;
    final playerName = prefs.getString(_nameKey) ?? '';
    final colorVal = prefs.getInt(_colorKey);
    final avatarColor = colorVal != null ? Color(colorVal) : const Color(0xFF7B2FBE);

    emit(OnboardingState(
      completed: completed,
      playerName: playerName,
      avatarColor: avatarColor,
      loading: false,
    ));
  }

  void _onNextStep(OnboardingNextStep event, Emitter<OnboardingState> emit) {
    if (state.currentStep < 4) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onSetPlayerName(OnboardingSetPlayerName event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(playerName: event.name.trim()));
  }

  void _onSetAvatarColor(OnboardingSetAvatarColor event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(avatarColor: event.color));
  }

  void _onTutorialSelect(OnboardingTutorialSelect event, Emitter<OnboardingState> emit) {
    final correct = event.index == 0;
    emit(state.copyWith(
      tutorialSelectedIndex: event.index,
      tutorialCorrect: correct,
      tutorialAnswered: correct,
      tutorialWrongAttempts: correct ? state.tutorialWrongAttempts : state.tutorialWrongAttempts + 1,
    ));
  }

  void _onComplete(OnboardingComplete event, Emitter<OnboardingState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_doneKey, true);
    await prefs.setString(_nameKey, state.playerName.isNotEmpty ? state.playerName : 'Adventurer');
    await prefs.setInt(_colorKey, state.avatarColor.toARGB32());
    emit(state.copyWith(completed: true));
  }
}
