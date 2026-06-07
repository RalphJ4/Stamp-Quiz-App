import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'domain/entities/leaderboard_period.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseInitialized = await _initFirebase();
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
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Stamp Quiz',
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF0D0D1A),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF7B2FBE),
                secondary: Color(0xFFE8B86D),
                surface: Color(0xFF1A1A2E),
              ),
            ),
            home: BlocBuilder<OnboardingBloc, OnboardingState>(
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
          );
        },
      ),
    );
  }
}
