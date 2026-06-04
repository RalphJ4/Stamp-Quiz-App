import 'package:hive/hive.dart';

class LocalStorageService {
  static const _quizBoxName = 'quiz_cache';
  static const _scoreBoxName = 'score_history';

  Future<Box> _openQuizBox() => Hive.openBox(_quizBoxName);
  Future<Box> _openScoreBox() => Hive.openBox(_scoreBoxName);

  Future<void> cacheQuestions(String json) async {
    final box = await _openQuizBox();
    await box.put('questions', json);
    await box.put('cached_at', DateTime.now().toIso8601String());
  }

  Future<String?> getCachedQuestions() async {
    final box = await _openQuizBox();
    return box.get('questions') as String?;
  }

  Future<bool> hasCachedQuestions() async {
    final box = await _openQuizBox();
    return box.containsKey('questions');
  }

  Future<void> saveScore({
    required String sessionId,
    required int score,
    required int total,
    required int stampsEarned,
  }) async {
    final box = await _openScoreBox();
    final scores = box.get(sessionId, defaultValue: <Map<String, dynamic>>[]) as List;
    final updated = List<Map<String, dynamic>>.from(scores)
      ..add({
        'score': score,
        'total': total,
        'stampsEarned': stampsEarned,
        'date': DateTime.now().toIso8601String(),
      });
    await box.put(sessionId, updated);
  }

  Future<List<Map<String, dynamic>>> getScores(String sessionId) async {
    final box = await _openScoreBox();
    final data = box.get(sessionId, defaultValue: <Map<String, dynamic>>[]) as List;
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> clearAll() async {
    final quizBox = await _openQuizBox();
    await quizBox.clear();
    final scoreBox = await _openScoreBox();
    await scoreBox.clear();
  }
}
