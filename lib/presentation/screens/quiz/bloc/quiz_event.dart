import '../../../../domain/entities/question.dart';

sealed class QuizEvent {}

final class QuizLoadQuestions extends QuizEvent {}

final class QuizSelectCategory extends QuizEvent {
  final QuestionCategory category;
  QuizSelectCategory({required this.category});
}

final class QuizStartTimer extends QuizEvent {}

final class QuizPauseTimer extends QuizEvent {}

final class QuizTimerTick extends QuizEvent {}

final class QuizSelectOption extends QuizEvent {
  final int index;
  QuizSelectOption({required this.index});
}

final class QuizNextQuestion extends QuizEvent {}

final class QuizFinish extends QuizEvent {}

final class QuizUseHint extends QuizEvent {}

final class QuizDeductStamps extends QuizEvent {
  final int amount;
  QuizDeductStamps({required this.amount});
}

final class QuizAwardStamps extends QuizEvent {
  final int amount;
  QuizAwardStamps({required this.amount});
}

final class QuizAddHint extends QuizEvent {}

final class QuizReset extends QuizEvent {}
