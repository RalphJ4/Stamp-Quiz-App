import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/duel.dart';
import '../../domain/entities/question.dart';
import '../../data/models/question_model.dart';

class DuelDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _duels => _firestore.collection('duels');

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = _random;
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  final _random = Random();

  Future<String> createDuel(String hostUid, List<Question> questions) async {
    const maxAttempts = 5;
    String code;
    int attempt = 0;
    do {
      code = _generateCode();
      attempt++;
      final existing = await _duels.doc(code).get();
      if (!existing.exists) break;
    } while (attempt < maxAttempts);

    await _duels.doc(code).set({
      'hostUid': hostUid,
      'guestUid': null,
      'status': 'waiting',
      'hostScore': 0,
      'guestScore': 0,
      'hostProgress': 0,
      'guestProgress': 0,
      'questions': questions
          .map((q) => QuestionModel(
                id: q.id,
                question: q.question,
                options: q.options,
                correctIndex: q.correctIndex,
                category: q.category,
                difficulty: q.difficulty,
              ).toMap())
          .toList(),
      'startedAt': FieldValue.serverTimestamp(),
      'winnerUid': null,
    });
    return code;
  }

  Future<void> joinDuel(String duelId, String guestUid) async {
    await _duels.doc(duelId).update({
      'guestUid': guestUid,
      'status': 'active',
    });
  }

  Stream<DuelState?> streamDuel(String duelId) {
    return _duels.doc(duelId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return _fromSnapshot(snap.id, snap.data() as Map<String, dynamic>);
    });
  }

  Future<void> submitAnswer(
      String duelId, String uid, bool isCorrect, int newProgress) async {
    final doc = _duels.doc(duelId);
    final snap = await doc.get();
    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;
    final isHost = data['hostUid'] == uid;

    final fieldPrefix = isHost ? 'host' : 'guest';

    await doc.update({
      '${fieldPrefix}Score': FieldValue.increment(isCorrect ? 1 : 0),
      '${fieldPrefix}Progress': newProgress,
    });
  }

  Future<void> finishDuel(String duelId, String? winnerUid) async {
    await _duels.doc(duelId).update({
      'status': 'complete',
      'winnerUid': winnerUid,
    });
  }

  Future<void> deleteDuel(String duelId) async {
    await _duels.doc(duelId).delete();
  }

  DuelState _fromSnapshot(String id, Map<String, dynamic> data) {
    final questionsRaw = data['questions'] as List<dynamic>? ?? [];
    final questions = questionsRaw
        .map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
        .toList();

    final startedAt = (data['startedAt'] as Timestamp?)?.toDate() ??
        DateTime.now();

    return DuelState(
      duelId: id,
      hostUid: data['hostUid'] as String,
      guestUid: data['guestUid'] as String?,
      status: _parseStatus(data['status'] as String?),
      hostScore: (data['hostScore'] as int?) ?? 0,
      guestScore: (data['guestScore'] as int?) ?? 0,
      hostProgress: (data['hostProgress'] as int?) ?? 0,
      guestProgress: (data['guestProgress'] as int?) ?? 0,
      questions: questions,
      startedAt: startedAt,
      winnerUid: data['winnerUid'] as String?,
    );
  }

  DuelStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return DuelStatus.active;
      case 'complete':
        return DuelStatus.complete;
      default:
        return DuelStatus.waiting;
    }
  }
}
