import 'question.dart';

class DailyChallenge {
  final String dateKey;
  final List<Question> questions;
  final List<String> completedBy;

  DailyChallenge({
    required this.dateKey,
    required this.questions,
    this.completedBy = const [],
  });

  bool isCompletedBy(String uid) => completedBy.contains(uid);
  int get stampReward => questions.length * 3;
}
