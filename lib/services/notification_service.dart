import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  NotificationService._();

  static final _log = Logger();
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static String? _currentToken;
  static bool _initialized = false;

  static const _dailyChallengeId = 1000;

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
    } catch (e) {
      _log.e('Failed to schedule daily reminder: $e');
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
    _log.i('Daily challenge reminder scheduled at ${scheduled.hour}:${scheduled.minute.toString().padLeft(2, '0')} PHT');
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

  /// Handle a tapped notification — navigate to the given route.
  static void handleNotificationTap(String? route) {
    if (route == null) return;
    _log.i('Notification tap → $route');
  }
}
