import 'package:flutter/material.dart';

sealed class OnboardingEvent {}

final class OnboardingLoadPreferences extends OnboardingEvent {}

final class OnboardingNextStep extends OnboardingEvent {}

final class OnboardingSetPlayerName extends OnboardingEvent {
  final String name;
  OnboardingSetPlayerName({required this.name});
}

final class OnboardingSetAvatarColor extends OnboardingEvent {
  final Color color;
  OnboardingSetAvatarColor({required this.color});
}

final class OnboardingComplete extends OnboardingEvent {}

final class OnboardingTutorialSelect extends OnboardingEvent {
  final int index;
  OnboardingTutorialSelect({required this.index});
}
