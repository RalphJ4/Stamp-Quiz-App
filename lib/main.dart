import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'domain/entities/leaderboard_period.dart';
import 'services/notification_service.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/auth/bloc/auth_bloc.dart';
import 'presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'presentation/screens/power_up/bloc/power_up_bloc.dart';
import 'presentation/screens/daily_challenge/bloc/daily_challenge_bloc.dart';
import 'presentation/screens/duel/bloc/duel_bloc.dart';
import 'presentation/screens/onboarding/bloc/onboarding_bloc.dart';
import 'presentation/screens/leaderboard/bloc/leaderboard_bloc.dart';
import 'presentation/screens/onboarding/gamified_onboarding_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

/// Called when a push notification arrives while the app is terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Logger().i('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseInitialized = await _initFirebase();
  if (firebaseInitialized) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    try {
      await NotificationService.init();
    } catch (e) {
      dev.log('NotificationService init failed: $e');
    }
  }
  await Hive.initFlutter();
  await Hive.openBox('quiz_cache');
  await Hive.openBox('score_history');
  runApp(QuizApp(firebaseInitialized: firebaseInitialized));
}

Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (e) {
    dev.log('Firebase initialization error: $e');
    return false;
  }
}

class QuizApp extends StatelessWidget {
  final bool firebaseInitialized;
  const QuizApp({super.key, required this.firebaseInitialized});

  static final _log = Logger();

  @override
  Widget build(BuildContext context) {
    if (!firebaseInitialized) {
      return _buildErrorApp(context);
    }
    return _buildApp(context);
  }

  Widget _buildErrorApp(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Stamp Quiz',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Firebase not configured for this platform',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Run "flutterfire configure --platforms=web" in your project root to set up Firebase for web.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApp(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (ctx) => QuizBloc(ctx.read<AuthBloc>())..add(QuizLoadQuestions())),
        BlocProvider(create: (ctx) => PowerUpBloc(ctx.read<AuthBloc>(), ctx.read<QuizBloc>())..add(PowerUpFetchInventory())),
        BlocProvider(create: (ctx) => DailyChallengeBloc(ctx.read<AuthBloc>())..add(DailyChallengeLoadToday())),
        BlocProvider(create: (ctx) => DuelBloc(ctx.read<AuthBloc>(), ctx.read<QuizBloc>())),
        BlocProvider(create: (ctx) => OnboardingBloc()..add(OnboardingLoadPreferences())),
        BlocProvider(create: (ctx) => LeaderboardBloc(ctx.read<AuthBloc>(), ctx.read<QuizBloc>())..add(LeaderboardFetchPeriod(period: LeaderboardPeriod.allTime))),
      ],
      child: _NotificationListenerWidget(
        key: const ValueKey('notification_listener'),
      ),
    );
  }
}

/// Listens for FCM messages and notification taps.
class _NotificationListenerWidget extends StatefulWidget {
  const _NotificationListenerWidget({super.key});

  @override
  State<_NotificationListenerWidget> createState() => _NotificationListenerWidgetState();
}

class _NotificationListenerWidgetState extends State<_NotificationListenerWidget> {
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _tapSub;

  @override
  void initState() {
    super.initState();
    _foregroundSub = FirebaseMessaging.onMessage.listen(NotificationService.showLocalNotification);
    _tapSub = FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      NotificationService.handleNotificationTap(msg.data['route']);
    });
    FirebaseMessaging.instance.getInitialMessage().then((msg) {
      if (msg != null) NotificationService.handleNotificationTap(msg.data['route']);
    });
  }

  @override
  void dispose() {
    _foregroundSub?.cancel();
    _tapSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          navigatorKey: NotificationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Stamp Quiz',
          theme: AppTheme.dark,
          home: BlocListener<QuizBloc, QuizState>(
            listenWhen: (prev, curr) => prev.stamps != curr.stamps || prev.totalAnswered != curr.totalAnswered || prev.bestStreak != curr.bestStreak,
            listener: (context, state) {
              NotificationService.checkAndNotifyAchievements(state);
            },
            child: BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, onboarding) {
              return BlocBuilder<AuthBloc, AuthState>(
                builder: (context, auth) {
                  if (!auth.initialized || onboarding.loading) {
                    QuizApp._log.i('🔄 loading');
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!onboarding.completed) {
                    QuizApp._log.i('🎮 GamifiedOnboarding');
                    return GamifiedOnboardingScreen(
                      onComplete: () {
                        context.read<AuthBloc>().add(AuthStartGuestSession());
                      },
                    );
                  }
                  if (auth.mode == AuthMode.none) {
                    QuizApp._log.i('🖥 OnboardingScreen');
                    return const OnboardingScreen();
                  }
                  QuizApp._log.i('🏠 HomeScreen');
                  return const HomeScreen();
                },
              );
            },
          ),
        ),
        );
      },
    );
  }
}
