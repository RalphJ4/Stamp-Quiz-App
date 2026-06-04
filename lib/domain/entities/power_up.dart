import 'package:flutter/material.dart';

enum PowerUpType {
  timeFreeze,
  doubleXp,
  extraHint,
  skipQuestion,
}

extension PowerUpTypeMeta on PowerUpType {
  String get label {
    switch (this) {
      case PowerUpType.timeFreeze:
        return 'Time Freeze';
      case PowerUpType.doubleXp:
        return 'Double XP';
      case PowerUpType.extraHint:
        return 'Extra Hint';
      case PowerUpType.skipQuestion:
        return 'Skip Question';
    }
  }

  int get cost {
    switch (this) {
      case PowerUpType.timeFreeze:
        return 30;
      case PowerUpType.doubleXp:
        return 50;
      case PowerUpType.extraHint:
        return 20;
      case PowerUpType.skipQuestion:
        return 40;
    }
  }

  String get description {
    switch (this) {
      case PowerUpType.timeFreeze:
        return '+10 seconds on timed questions';
      case PowerUpType.doubleXp:
        return 'Next correct answer gives 2× XP';
      case PowerUpType.extraHint:
        return '+1 hint for this session';
      case PowerUpType.skipQuestion:
        return 'Skip without losing streak';
    }
  }

  IconData get icon {
    switch (this) {
      case PowerUpType.timeFreeze:
        return Icons.ac_unit;
      case PowerUpType.doubleXp:
        return Icons.stars;
      case PowerUpType.extraHint:
        return Icons.lightbulb;
      case PowerUpType.skipQuestion:
        return Icons.skip_next;
    }
  }

  Color get color {
    switch (this) {
      case PowerUpType.timeFreeze:
        return const Color(0xFF42A5F5);
      case PowerUpType.doubleXp:
        return const Color(0xFFE8B86D);
      case PowerUpType.extraHint:
        return const Color(0xFF66BB6A);
      case PowerUpType.skipQuestion:
        return const Color(0xFFFF6B6B);
    }
  }

  String get firestoreKey {
    switch (this) {
      case PowerUpType.timeFreeze:
        return 'timeFreeze';
      case PowerUpType.doubleXp:
        return 'doubleXp';
      case PowerUpType.extraHint:
        return 'extraHint';
      case PowerUpType.skipQuestion:
        return 'skipQuestion';
    }
  }

  static PowerUpType fromFirestoreKey(String key) {
    return PowerUpType.values.firstWhere(
      (t) => t.firestoreKey == key,
      orElse: () => PowerUpType.timeFreeze,
    );
  }
}
