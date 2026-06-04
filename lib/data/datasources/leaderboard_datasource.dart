import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/leaderboard_period.dart';

class LeaderboardDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _leaderboard => _firestore.collection('leaderboard');

  Future<List<LeaderboardEntry>> fetchLeaderboard(LeaderboardPeriod period) async {
    final field = period.firestoreField;
    final snapshot = await _leaderboard
        .orderBy(field, descending: true)
        .limit(100)
        .get();

    final entries = <LeaderboardEntry>[];
    var rank = 1;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      entries.add(LeaderboardEntry(
        uid: doc.id,
        displayName: data['displayName'] as String? ?? 'Anonymous',
        allTimeXp: (data['allTimeXp'] as int?) ?? 0,
        weeklyXp: (data['weeklyXp'] as int?) ?? 0,
        monthlyXp: (data['monthlyXp'] as int?) ?? 0,
        rank: rank++,
      ));
    }
    return entries;
  }

  Future<int> getUserRank(String uid, LeaderboardPeriod period) async {
    final field = period.firestoreField;
    final entry = await getUserEntry(uid);
    if (entry == null) return 0;

    final userXp = entry.xpForPeriod(period);
    if (userXp <= 0) return 0;

    final snapshot = await _leaderboard
        .where(field, isGreaterThan: userXp)
        .get();

    return snapshot.docs.length + 1;
  }

  Future<LeaderboardEntry?> getUserEntry(String uid) async {
    final doc = await _leaderboard.doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? 'Anonymous',
      allTimeXp: (data['allTimeXp'] as int?) ?? 0,
      weeklyXp: (data['weeklyXp'] as int?) ?? 0,
      monthlyXp: (data['monthlyXp'] as int?) ?? 0,
      rank: 0,
    );
  }

  Future<void> syncXp(String uid, {
    required int allTimeXp,
    required int weeklyXp,
    required int monthlyXp,
    required String displayName,
  }) async {
    await _leaderboard.doc(uid).set({
      'uid': uid,
      'displayName': displayName,
      'allTimeXp': allTimeXp,
      'weeklyXp': weeklyXp,
      'monthlyXp': monthlyXp,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
