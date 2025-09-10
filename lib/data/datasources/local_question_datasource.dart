import '../models/question_model.dart';

class LocalQuestionDataSource {
  Future<List<QuestionModel>> getLocalQuestions() async {
    final raw = [
      {
        'id': 'q1',
        'question': "Which planet is known as the 'Red Planet'?",
        'options': ['Mercury', 'Venus', 'Mars', 'Jupiter'],
        'correctIndex': 2,
      },
      {
        'id': 'q2',
        'question': 'What is the name of the galaxy that contains our Solar System?',
        'options': ['The Andromeda Galaxy', 'The Milky Way Galaxy', 'The Whirlpool Galaxy', 'The Black Eye Galaxy'],
        'correctIndex': 1,
      },
      {
        'id': 'q3',
        'question': 'Which planet has the most moons?',
        'options': ['Earth', 'Jupiter', 'Saturn', 'Neptune'],
        'correctIndex': 1,
      },
      {
        'id': 'q4',
        'question': 'What is a supernova?',
        'options': ['A collision of two stars', 'A black hole eating a star', 'The explosion of a star', 'A new star being born'],
        'correctIndex': 2,
      },
      {
        'id': 'q5',
        'question': 'Who was the first woman to travel into space?',
        'options': ['Sally Ride', 'Valentina Tereshkova', 'Mae Jemison', 'Kalpana Chawla'],
        'correctIndex': 1,
      },
    ];

    await Future.delayed(const Duration(milliseconds: 200));
    return raw.map((m) => QuestionModel.fromMap(m)).toList();
  }
}
