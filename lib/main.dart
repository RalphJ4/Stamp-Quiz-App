import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/presentation/provider/quiz_provider.dart';
import 'package:quiz_app/presentation/screens/home_screen.dart';
import 'package:quiz_app/presentation/screens/onboarding_screen.dart';
import 'package:quiz_app/services/auth_mode_manager.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModeManager()..initialize()),
        ChangeNotifierProvider(create: (ctx) => QuizProvider(ctx.read<AuthModeManager>())..loadQuestions()),
      ],
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Stamp Quiz',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: Consumer<AuthModeManager>(
              builder: (context, auth, _) {
                if (!auth.initialized) {
                  QuizApp._log.i('🔄 loading');
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (auth.mode == AuthMode.none) {
                  QuizApp._log.i('🖥 OnboardingScreen');
                  return const OnboardingScreen();
                }
                QuizApp._log.i('🏠 HomeScreen');
                return const HomeScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
