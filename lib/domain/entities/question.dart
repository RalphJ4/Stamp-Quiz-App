enum QuestionCategory { space, animals, history, science, geography, japanese }

enum QuestionDifficulty { easy, medium, hard }

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final QuestionCategory category;
  final QuestionDifficulty difficulty;
  final String? jlptLevel;
  final String? subCategory;
  final String? explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.category = QuestionCategory.space,
    this.difficulty = QuestionDifficulty.easy,
    this.jlptLevel,
    this.subCategory,
    this.explanation,
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
