import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';

class OnboardingState extends Equatable {
  final int currentStep;
  final String playerName;
  final Color avatarColor;
  final bool completed;
  final bool loading;
  final int tutorialSelectedIndex;
  final bool tutorialCorrect;
  final bool tutorialAnswered;
  final int tutorialWrongAttempts;

  const OnboardingState({
    this.currentStep = 0,
    this.playerName = '',
    this.avatarColor = AppColors.primary,
    this.completed = false,
    this.loading = true,
    this.tutorialSelectedIndex = -1,
    this.tutorialCorrect = false,
    this.tutorialAnswered = false,
    this.tutorialWrongAttempts = 0,
  });

  static const List<Color> presetColors = [
    AppColors.primary,
    Color(0xFFFF6B6B),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    AppColors.secondary,
  ];

  int get stepCount => 5;

  OnboardingState copyWith({
    int? currentStep,
    String? playerName,
    Color? avatarColor,
    bool? completed,
    bool? loading,
    int? tutorialSelectedIndex,
    bool? tutorialCorrect,
    bool? tutorialAnswered,
    int? tutorialWrongAttempts,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      playerName: playerName ?? this.playerName,
      avatarColor: avatarColor ?? this.avatarColor,
      completed: completed ?? this.completed,
      loading: loading ?? this.loading,
      tutorialSelectedIndex: tutorialSelectedIndex ?? this.tutorialSelectedIndex,
      tutorialCorrect: tutorialCorrect ?? this.tutorialCorrect,
      tutorialAnswered: tutorialAnswered ?? this.tutorialAnswered,
      tutorialWrongAttempts: tutorialWrongAttempts ?? this.tutorialWrongAttempts,
    );
  }

  @override
  List<Object?> get props => [
    currentStep, playerName, avatarColor, completed, loading,
    tutorialSelectedIndex, tutorialCorrect, tutorialAnswered, tutorialWrongAttempts,
  ];
}

