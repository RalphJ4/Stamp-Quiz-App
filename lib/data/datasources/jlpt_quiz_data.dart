import 'dart:convert';
import 'package:flutter/services.dart';

class JlptQuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String subCategory;
  final String difficulty;

  const JlptQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.subCategory,
    required this.difficulty,
  });
}

class JlptQuizDataLoader {
  static Map<String, List<JlptQuizQuestion>>? _cached;

  static Future<Map<String, List<JlptQuizQuestion>>> load() async {
    if (_cached != null) return _cached!;

    final jsonString = await rootBundle.loadString('assets/data/jlpt_questions.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final levels = data['levels'] as Map<String, dynamic>;

    final result = <String, List<JlptQuizQuestion>>{};

    for (final level in levels.keys) {
      final subCategories = levels[level] as Map<String, dynamic>;
      final questions = <JlptQuizQuestion>[];

      for (final subCat in subCategories.keys) {
        final qList = subCategories[subCat] as List<dynamic>;
        for (final q in qList) {
          final qMap = q as Map<String, dynamic>;
          questions.add(JlptQuizQuestion(
            id: qMap['id'] as String,
            question: qMap['question'] as String,
            options: List<String>.from(qMap['options'] as List<dynamic>),
            correctIndex: qMap['correctIndex'] as int,
            explanation: qMap['explanation'] as String,
            subCategory: subCat,
            difficulty: qMap['difficulty'] as String? ?? _difficultyForLevel(level),
          ));
        }
      }

      result[level] = questions;
    }

    _cached = result;
    return result;
  }

  static String _difficultyForLevel(String level) {
    switch (level) {
      case 'N5':
      case 'N4':
        return 'easy';
      case 'N3':
        return 'medium';
      case 'N2':
      case 'N1':
        return 'hard';
      default:
        return 'medium';
    }
  }
}
