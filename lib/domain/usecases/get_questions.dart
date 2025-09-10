import '../entities/question.dart';
import '../repositories/question_repository.dart';

class GetQuestions {
  final QuestionRepository repository;
  GetQuestions(this.repository);

  Future<List<Question>> execute() async {
    return await repository.getQuestions();
  }
}
