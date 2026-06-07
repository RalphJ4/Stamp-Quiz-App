import 'package:equatable/equatable.dart';
import '../../../../domain/entities/question.dart';

class CategoryStats extends Equatable {
  final String category;
  final int stamps;

  const CategoryStats({required this.category, required this.stamps});

  @override
  List<Object?> get props => [category, stamps];
}

class QuizState extends Equatable {
  final List<Question> allQuestions;
  final List<Question> questions;
  final int currentIndex;
  final int stamps;
  final bool answered;
  final int? selectedOption;
  final bool animateStamp;
  final bool isQuizFinished;
  final int hintsRemaining;
  final bool usedHint;
  final Set<int> eliminatedOptions;
  final bool quizStarted;
  final int remainingSeconds;
  final QuestionCategory selectedCategory;
  final int currentStreak;
  final int bestStreak;
  final int totalCorrect;
  final int totalAnswered;

  const QuizState({
    this.allQuestions = const [],
    this.questions = const [],
    this.currentIndex = 0,
    this.stamps = 0,
    this.answered = false,
    this.selectedOption,
    this.animateStamp = false,
    this.isQuizFinished = false,
    this.hintsRemaining = 3,
    this.usedHint = false,
    this.eliminatedOptions = const {},
    this.quizStarted = false,
    this.remainingSeconds = 30,
    this.selectedCategory = QuestionCategory.space,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCorrect = 0,
    this.totalAnswered = 0,
  });

  bool get isQuizInProgress => quizStarted && !isQuizFinished;

  QuizState copyWith({
    List<Question>? allQuestions,
    List<Question>? questions,
    int? currentIndex,
    int? stamps,
    bool? answered,
    bool clearSelectedOption = false,
    int? selectedOption,
    bool? animateStamp,
    bool? isQuizFinished,
    int? hintsRemaining,
    bool? usedHint,
    Set<int>? eliminatedOptions,
    bool? quizStarted,
    int? remainingSeconds,
    QuestionCategory? selectedCategory,
    int? currentStreak,
    int? bestStreak,
    int? totalCorrect,
    int? totalAnswered,
  }) {
    return QuizState(
      allQuestions: allQuestions ?? this.allQuestions,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      stamps: stamps ?? this.stamps,
      answered: answered ?? this.answered,
      selectedOption: clearSelectedOption ? null : (selectedOption ?? this.selectedOption),
      animateStamp: animateStamp ?? this.animateStamp,
      isQuizFinished: isQuizFinished ?? this.isQuizFinished,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      usedHint: usedHint ?? this.usedHint,
      eliminatedOptions: eliminatedOptions ?? this.eliminatedOptions,
      quizStarted: quizStarted ?? this.quizStarted,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalAnswered: totalAnswered ?? this.totalAnswered,
    );
  }

  @override
  List<Object?> get props => [
    allQuestions, questions, currentIndex, stamps, answered, selectedOption,
    animateStamp, isQuizFinished, hintsRemaining, usedHint, eliminatedOptions,
    quizStarted, remainingSeconds, selectedCategory, currentStreak, bestStreak,
    totalCorrect, totalAnswered,
  ];
}
