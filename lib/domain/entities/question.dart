enum QuestionCategory { space, animals, history, science, geography }

enum QuestionDifficulty { easy, medium, hard }

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final QuestionCategory category;
  final QuestionDifficulty difficulty;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.category = QuestionCategory.space,
    this.difficulty = QuestionDifficulty.easy,
  });

  int get stampReward {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return 1;
      case QuestionDifficulty.medium:
        return 2;
      case QuestionDifficulty.hard:
        return 3;
    }
  }
}
