import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/local_question_datasource.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final LocalQuestionDataSource local;
  QuestionRepositoryImpl({required this.local});

  @override
  Future<List<Question>> getQuestions() async {
    final models = await local.getLocalQuestions();
    return models;
  }
}
