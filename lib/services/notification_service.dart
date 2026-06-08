import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class NotificationService {
  NotificationService._();

  static final _log = Logger();
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static String? _currentToken;

  /// The latest FCM token for the current device.
  static String? get currentToken => _currentToken;

  /// Must be called once at app startup after Firebase is initialized.
  static Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      _log.w('Notification permission not granted');
      return;
    }
    await _initLocalNotifications();
    await _refreshToken();
    _messaging.onTokenRefresh.listen((token) {
      _currentToken = token;
      _log.i('FCM token refreshed');
    });
  }

  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> _refreshToken() async {
    _currentToken = await _messaging.getToken();
  }

  /// Show a local notification for an incoming message (foreground).
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
