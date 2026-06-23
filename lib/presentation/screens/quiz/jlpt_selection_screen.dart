import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/quiz_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';

final _log = Logger();

class JlptSelectionScreen extends StatelessWidget {
  const JlptSelectionScreen({super.key});

  static const _levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  static const _levelColors = {
    'N5': Color(0xFF66BB6A),
    'N4': Color(0xFF42A5F5),
    'N3': Color(0xFFFFA726),
    'N2': Color(0xFFFF6B6B),
    'N1': Color(0xFFE53935),
  };

  static const _levelLabels = {
    'N5': 'Beginner',
    'N4': 'Elementary',
    'N3': 'Intermediate',
    'N2': 'Pre-Advanced',
    'N1': 'Advanced',
  };

  static const _levelDescriptions = {
    'N5': 'Basic Japanese - hiragana, katakana, simple greetings',
    'N4': 'Everyday conversations and basic kanji',
    'N3': 'More complex grammar and intermediate vocabulary',
    'N2': 'Advanced reading and nuanced expressions',
    'N1': 'Mastery level - complex texts and idioms',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select JLPT Level', style: TextStyle(color: AppColors.secondary)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        toolbarHeight: 7.h,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            Text(
              'Choose your JLPT level',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Questions follow the JLPT style for each level.',
              style: TextStyle(fontSize: 16.sp, color: Colors.white54),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: ListView.separated(
                itemCount: _levels.length,
                separatorBuilder: (_, __) => SizedBox(height: 2.h),
                itemBuilder: (context, index) {
                  final level = _levels[index];
                  final color = _levelColors[level]!;
                  final label = _levelLabels[level]!;
                  final desc = _levelDescriptions[level]!;
                  return GestureDetector(
                    onTap: () {
                      context.read<QuizBloc>().add(QuizSelectJlptLevel(level: level));
                      _log.i('→ QuizScreen ($level)');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 16.w,
                            height: 16.w,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                level,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                SizedBox(height: 0.3.h),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: color.withValues(alpha: 0.8),
                                  ),
                                ),
                                SizedBox(height: 0.2.h),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: color, size: 5.w),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
