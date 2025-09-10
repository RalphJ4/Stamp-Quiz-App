import '../entities/question.dart';

abstract class QuestionRepository {
  Future<List<Question>> getQuestions();
}
