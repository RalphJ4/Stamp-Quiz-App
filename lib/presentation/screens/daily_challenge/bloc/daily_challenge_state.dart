import 'package:equatable/equatable.dart';
import '../../../../domain/entities/daily_challenge.dart';
import '../../../../domain/entities/question.dart';

class DailyChallengeState extends Equatable {
  final DailyChallenge? challenge;
  final bool loading;
  final bool completed;
  final int currentIndex;
  final bool answered;
  final int? selectedOption;
  final int correctCount;
  final int dailyStreak;

  const DailyChallengeState({
    this.challenge,
    this.loading = true,
    this.completed = false,
    this.currentIndex = 0,
    this.answered = false,
    this.selectedOption,
    this.correctCount = 0,
    this.dailyStreak = 0,
  });

  bool get isFinished => currentIndex >= (challenge?.questions.length ?? 0);

  Question? get currentQuestion {
    if (challenge == null || currentIndex >= challenge!.questions.length) return null;
    return challenge!.questions[currentIndex];
  }

  DailyChallengeState copyWith({
    DailyChallenge? challenge,
    bool? loading,
    bool? completed,
    int? currentIndex,
    bool? answered,
    int? selectedOption,
    int? correctCount,
    int? dailyStreak,
  }) {
    return DailyChallengeState(
      challenge: challenge ?? this.challenge,
      loading: loading ?? this.loading,
      completed: completed ?? this.completed,
      currentIndex: currentIndex ?? this.currentIndex,
      answered: answered ?? this.answered,
      selectedOption: selectedOption ?? this.selectedOption,
      correctCount: correctCount ?? this.correctCount,
      dailyStreak: dailyStreak ?? this.dailyStreak,
    );
  }

  String get timeUntilReset {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    challenge, loading, completed, currentIndex, answered,
    selectedOption, correctCount, dailyStreak,
  ];
}
