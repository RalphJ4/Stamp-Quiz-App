import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/power_up.dart';

class PowerUpShopDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<Map<PowerUpType, int>> fetchInventory(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return {};

    final data = doc.data() as Map<String, dynamic>?;
    final inventoryRaw = data?['inventory'] as Map<String, dynamic>? ?? {};

    return {
      for (final entry in inventoryRaw.entries)
        PowerUpTypeMeta.fromFirestoreKey(entry.key):
            (entry.value as int?) ?? 0,
    };
  }

  Future<String?> purchase(String uid, PowerUpType type, int cost) async {
    try {
      await _firestore.runTransaction((txn) async {
        final snapshot = await txn.get(_userDoc(uid));

        final data = Map<String, dynamic>.from(
            snapshot.exists ? (snapshot.data() as Map<String, dynamic>? ?? {}) : {});

        final inventoryRaw =
            Map<String, dynamic>.from(data['inventory'] as Map? ?? {});
        final currentCount = (inventoryRaw[type.firestoreKey] as int?) ?? 0;
        inventoryRaw[type.firestoreKey] = currentCount + 1;

        txn.set(_userDoc(uid), {'inventory': inventoryRaw}, SetOptions(merge: true));
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> decrementInventory(String uid, PowerUpType type) async {
    await _firestore.runTransaction((txn) async {
      final snapshot = await txn.get(_userDoc(uid));
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final inventoryRaw =
          Map<String, dynamic>.from(data['inventory'] as Map? ?? {});
      final currentCount = (inventoryRaw[type.firestoreKey] as int?) ?? 0;
      final newCount = currentCount - 1;
      if (newCount <= 0) {
        inventoryRaw.remove(type.firestoreKey);
      } else {
        inventoryRaw[type.firestoreKey] = newCount;
      }

      txn.update(_userDoc(uid), {'inventory': inventoryRaw});
    });
  }
}
