import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/presentation/provider/quiz_provider.dart';
import 'package:quiz_app/presentation/screens/home_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => QuizProvider()..loadQuestions())],
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Quiz App',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
