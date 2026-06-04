import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/daily_challenge.dart';
import '../../domain/entities/question.dart';

class DailyChallengeModel {
  static DailyChallenge fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final questions = (data['questions'] as List).map((q) {
      final qm = q as Map<String, dynamic>;
      return Question(
        id: qm['id'] as String,
        question: qm['question'] as String,
        options: List<String>.from(qm['options'] as List),
        correctIndex: qm['correctIndex'] as int,
        category: QuestionCategory.values.firstWhere(
          (c) => c.name == qm['category'],
          orElse: () => QuestionCategory.space,
        ),
        difficulty: QuestionDifficulty.values.firstWhere(
          (d) => d.name == qm['difficulty'],
          orElse: () => QuestionDifficulty.easy,
        ),
      );
    }).toList();
    return DailyChallenge(
      dateKey: doc.id,
      questions: questions,
      completedBy: List<String>.from(data['completedBy'] as List? ?? []),
    );
  }

  static Map<String, dynamic> toFirestore(DailyChallenge challenge) {
    return {
      'completedBy': challenge.completedBy,
      'questions': challenge.questions.map((q) => {
        'id': q.id,
        'question': q.question,
        'options': q.options,
        'correctIndex': q.correctIndex,
        'category': q.category.name,
        'difficulty': q.difficulty.name,
      }).toList(),
    };
  }
}
