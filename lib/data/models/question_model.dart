import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  QuestionModel({
    required super.id,
    required super.question,
    required super.options,
    required super.correctIndex,
    super.category,
    super.difficulty,
    super.jlptLevel,
    super.subCategory,
    super.explanation,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as String,
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List<dynamic>),
      correctIndex: map['correctIndex'] as int,
      category: QuestionCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => QuestionCategory.space,
      ),
      difficulty: QuestionDifficulty.values.firstWhere(
        (d) => d.name == map['difficulty'],
        orElse: () => QuestionDifficulty.easy,
      ),
      jlptLevel: map['jlptLevel'] as String?,
      subCategory: map['subCategory'] as String?,
      explanation: map['explanation'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'category': category.name,
    'difficulty': difficulty.name,
    if (jlptLevel != null) 'jlptLevel': jlptLevel,
    if (subCategory != null) 'subCategory': subCategory,
    if (explanation != null) 'explanation': explanation,
  };
}
