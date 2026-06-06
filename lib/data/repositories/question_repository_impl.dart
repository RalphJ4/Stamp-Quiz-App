import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/ai_question_datasource.dart';
import '../datasources/local_question_datasource.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final LocalQuestionDataSource local;
  final AiQuestionDataSource ai;
  QuestionRepositoryImpl({required this.local, required this.ai});

  @override
  Future<List<Question>> getQuestions() async {
    final localQuestions = await local.getLocalQuestions();
    try {
      final aiQuestions = await ai.generateQuestionsForAllCategories(perCategory: 3);
      if (aiQuestions.isNotEmpty) {
        return [...localQuestions, ...aiQuestions];
      }
    } catch (_) {}
    return localQuestions;
  }
}
