import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:quiz_app/presentation/screens/daily_challenge/daily_challenge_screen.dart';
import 'package:quiz_app/presentation/screens/leaderboard/leaderboard_screen.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_state.dart';

class NotificationService {
  NotificationService._();

  static final _log = Logger();
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static String? _currentToken;
  static bool _initialized = false;

  static const _dailyChallengeId = 1000;
  static const _streakReminderId = 1001;
  static const _notifiedBadgesKey = 'notified_badges';

  /// Global navigator key set by [QuizApp] for notification-tap navigation.
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// The latest FCM token for the current device.
  static String? get currentToken => _currentToken;

  /// Must be called once at app startup after Firebase is initialized.
  static Future<void> init() async {
    if (_initialized) return;
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        _log.w('Notification permission not granted');
      }
    } catch (e) {
      _log.e('Failed to request permission: $e');
    }
    try {
      tz_data.initializeTimeZones();
    } catch (e) {
      _log.e('Failed to initialize timezones: $e');
    }
    try {
      await _initLocalNotifications();
    } catch (e) {
      _log.e('Failed to init local notifications: $e');
    }
    try {
      await _refreshToken();
    } catch (e) {
      _log.e('Failed to get FCM token: $e');
    }
    _messaging.onTokenRefresh.listen((token) {
      _currentToken = token;
      _log.i('FCM token refreshed');
    });
    try {
      await scheduleDailyChallengeReminder();
      await scheduleStreakReminder();
    } catch (e) {
      _log.e('Failed to schedule reminders: $e');
    }
    _initialized = true;
  }

  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  static void _onNotificationResponse(NotificationResponse response) {
    handleNotificationTap(response.payload);
  }

  static Future<void> _refreshToken() async {
    _currentToken = await _messaging.getToken();
  }

  /// Schedule a daily notification at 8:00 AM PHT for the daily challenge.
  static Future<void> scheduleDailyChallengeReminder() async {
    await _localNotifications.cancel(id: _dailyChallengeId);

    const androidDetails = AndroidNotificationDetails(
      'daily_challenge_channel',
      'Daily Challenge',
      channelDescription: 'Reminders for daily challenges',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final pht = tz.getLocation('Asia/Manila');
    final now = tz.TZDateTime.now(pht);
    var scheduled = tz.TZDateTime(pht, now.year, now.month, now.day, 8, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await _localNotifications.zonedSchedule(
        id: _dailyChallengeId,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        title: 'Daily Challenge Available!',
        body: 'A new daily challenge is waiting. Complete it to earn bonus stamps!',
        payload: 'daily_challenge',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      _log.w('Exact schedule failed ($e), falling back to inexact');
      await _localNotifications.zonedSchedule(
        id: _dailyChallengeId,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: 'Daily Challenge Available!',
        body: 'A new daily challenge is waiting. Complete it to earn bonus stamps!',
        payload: 'daily_challenge',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Schedule a 6:00 PM PHT reminder to complete today's daily challenge.
  static Future<void> scheduleStreakReminder() async {
    await _localNotifications.cancel(id: _streakReminderId);

    const androidDetails = AndroidNotificationDetails(
      'daily_challenge_channel',
      'Daily Challenge',
      channelDescription: 'Reminders for daily challenges',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final pht = tz.getLocation('Asia/Manila');
    final now = tz.TZDateTime.now(pht);
    var scheduled = tz.TZDateTime(pht, now.year, now.month, now.day, 18, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await _localNotifications.zonedSchedule(
        id: _streakReminderId,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        title: 'Don\'t Lose Your Streak!',
        body: 'Today\'s daily challenge is still waiting. Keep your streak alive!',
        payload: 'daily_challenge',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      _log.w('Exact schedule failed ($e), falling back to inexact');
      await _localNotifications.zonedSchedule(
        id: _streakReminderId,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: 'Don\'t Lose Your Streak!',
        body: 'Today\'s daily challenge is still waiting. Keep your streak alive!',
        payload: 'daily_challenge',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Show a local notification for an incoming FCM message (foreground).
  static Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    const androidDetails = AndroidNotificationDetails(
      'stamp_quiz_channel',
      'Stamp Quiz',
      channelDescription: 'Notifications from Stamp Quiz',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: message.data['route'],
    );
  }

  /// Navigate to the screen associated with a notification tap.
  static void handleNotificationTap(String? route) {
    if (route == null || navigatorKey.currentState == null) return;
    _log.i('Notification tap → $route');
    switch (route) {
      case 'daily_challenge':
        navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (_) => const DailyChallengeScreen(),
        ));
      case 'leaderboard':
        navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (_) => const LeaderboardScreen(),
        ));
    }
  }

  /// Check for newly unlocked badges and fire notifications.
  static Future<void> checkAndNotifyAchievements(QuizState state) async {
    final prefs = await SharedPreferences.getInstance();
    final notified = (prefs.getStringList(_notifiedBadgesKey) ?? []).toSet();

    final badges = _badgesForState(state);
    final newlyUnlocked = <_BadgeInfo>[];
    for (final badge in badges) {
      if (badge.unlocked && !notified.contains(badge.id)) {
        newlyUnlocked.add(badge);
      }
    }

    if (newlyUnlocked.isEmpty) return;

    notified.addAll(newlyUnlocked.map((b) => b.id));
    await prefs.setStringList(_notifiedBadgesKey, notified.toList());

    for (final badge in newlyUnlocked) {
      await _localNotifications.show(
        id: badge.id.hashCode,
        title: 'Achievement Unlocked!',
        body: 'You earned the "${badge.name}" badge!',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'stamp_quiz_channel',
            'Stamp Quiz',
            channelDescription: 'Notifications from Stamp Quiz',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  /// Reset tracked notified badges (useful for testing / account reset).
  static Future<void> resetNotifiedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notifiedBadgesKey);
  }
}

class _BadgeInfo {
  final String id;
  final String name;
  final bool unlocked;
  const _BadgeInfo({required this.id, required this.name, required this.unlocked});
}

List<_BadgeInfo> _badgesForState(QuizState qp) {
  return [
    _BadgeInfo(id: 'first_stamp', name: 'First Stamp', unlocked: qp.stamps >= 1),
    _BadgeInfo(id: 'streak_3', name: 'On Fire', unlocked: qp.bestStreak >= 3),
    _BadgeInfo(id: 'streak_5', name: 'Streak Master', unlocked: qp.bestStreak >= 5),
    _BadgeInfo(id: 'double_digits', name: 'Double Digits', unlocked: qp.bestStreak >= 10),
    _BadgeInfo(id: 'century', name: 'Century', unlocked: qp.stamps >= 100),
    _BadgeInfo(id: 'quiz_whiz', name: 'Quiz Whiz', unlocked: qp.totalAnswered >= 50),
    _BadgeInfo(id: 'scholar', name: 'Scholar', unlocked: qp.stamps >= 500),
    _BadgeInfo(id: 'legend', name: 'Legend', unlocked: qp.stamps >= 1000),
    _BadgeInfo(id: 'sharpshooter', name: 'Sharpshooter', unlocked: qp.totalAnswered >= 20 && qp.totalCorrect / qp.totalAnswered >= 0.8),
    _BadgeInfo(id: 'grinder', name: 'Grinder', unlocked: qp.totalAnswered >= 100),
    _BadgeInfo(id: 'rising_star', name: 'Rising Star', unlocked: qp.stamps >= 250),
    _BadgeInfo(id: 'perfectionist', name: 'Perfectionist', unlocked: qp.totalAnswered >= 10 && qp.totalCorrect == qp.totalAnswered),
    _BadgeInfo(id: 'eagle_eye', name: 'Eagle Eye', unlocked: qp.totalAnswered >= 30 && qp.totalCorrect / qp.totalAnswered >= 0.9),
    _BadgeInfo(id: 'legendary_streak', name: 'Legendary Streak', unlocked: qp.bestStreak >= 20),
    _BadgeInfo(id: 'marathon', name: 'Marathon Runner', unlocked: qp.totalAnswered >= 500),
    _BadgeInfo(id: 'high_roller', name: 'High Roller', unlocked: qp.stamps >= 5000),
  ];
}
