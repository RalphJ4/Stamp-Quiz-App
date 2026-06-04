import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_challenge_model.dart';
import '../../domain/entities/daily_challenge.dart';
import 'local_question_datasource.dart';

class DailyChallengeDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalQuestionDataSource _local = LocalQuestionDataSource();

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  Future<DailyChallenge?> fetchToday() async {
    final doc = await _firestore.collection('dailyChallenges').doc(_todayKey).get();
    if (!doc.exists) return null;
    return DailyChallengeModel.fromFirestore(doc);
  }

  Future<DailyChallenge> getOrCreateToday() async {
    final existing = await fetchToday();
    if (existing != null) return existing;

    final allQuestions = await _local.getLocalQuestions();
    allQuestions.shuffle();
    final picked = allQuestions.take(5).toList();

    final challenge = DailyChallenge(
      dateKey: _todayKey,
      questions: picked,
    );

    await _firestore.collection('dailyChallenges').doc(_todayKey).set(
      DailyChallengeModel.toFirestore(challenge),
    );

    return challenge;
  }

  Future<void> markCompleted(String uid) async {
    await _firestore.collection('dailyChallenges').doc(_todayKey).update({
      'completedBy': FieldValue.arrayUnion([uid]),
    });
  }

  Future<int> getDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_streak') ?? 0;
  }

  Future<void> updateDailyStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_streak', streak);
    await prefs.setString('last_completed_date', _todayKey);
  }

  Future<void> checkAndResetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('last_completed_date');
    if (lastDate == null) return;

    final last = DateTime(int.parse(lastDate.substring(0, 4)),
        int.parse(lastDate.substring(4, 6)), int.parse(lastDate.substring(6, 8)));
    final diff = DateTime.now().difference(last).inDays;

    if (diff > 1) {
      await prefs.setInt('daily_streak', 0);
    }
  }
}
