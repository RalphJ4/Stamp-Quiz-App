import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/question.dart';

class AiQuestionDataSource {
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<List<Question>> generateQuestions(QuestionCategory category, {int count = 5}) async {
    final model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );

    final prompt = '''
You are a quiz question generator. Generate $count quiz questions about ${category.name}.
Return ONLY valid JSON array (no markdown, no backticks, no extra text):
[
  {
    "question": "Question text?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctIndex": 0,
    "difficulty": "easy"
  }
]
Rules:
- Each question must have exactly 4 options.
- correctIndex must be 0-3 and point to the correct option.
- difficulty must be "easy", "medium", or "hard".
- Mix of difficulties.
- Questions must be factual and educational.
- Do not repeat the same question.
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Empty response from Gemini');
    }

    final List<dynamic> jsonList = jsonDecode(text) as List<dynamic>;
    final now = DateTime.now().millisecondsSinceEpoch;

    return jsonList.asMap().entries.map((entry) {
      final i = entry.key;
      final m = entry.value as Map<String, dynamic>;
      return Question(
        id: 'ai_${category.name}_${now}_$i',
        question: m['question'] as String,
        options: List<String>.from(m['options'] as List<dynamic>),
        correctIndex: m['correctIndex'] as int,
        category: category,
        difficulty: QuestionDifficulty.values.firstWhere(
          (d) => d.name == m['difficulty'],
          orElse: () => QuestionDifficulty.easy,
        ),
      );
    }).toList();
  }

  Future<List<Question>> generateQuestionsForAllCategories({int perCategory = 3}) async {
    final all = <Question>[];
    for (final cat in QuestionCategory.values) {
      try {
        final qs = await generateQuestions(cat, count: perCategory);
        all.addAll(qs);
      } catch (_) {
        // skip category if generation fails
      }
    }
    return all;
  }
}
