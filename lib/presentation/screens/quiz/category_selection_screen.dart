import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/domain/entities/question.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/quiz_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';

final _log = Logger();

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  static const categoryColors = {
    QuestionCategory.space: Color(0xFF6C63FF),
    QuestionCategory.animals: Color(0xFFFF6B6B),
    QuestionCategory.history: Color(0xFFFFA726),
    QuestionCategory.science: Color(0xFF66BB6A),
    QuestionCategory.geography: Color(0xFF42A5F5),
  };

  static const categoryIcons = {
    QuestionCategory.space: Icons.rocket_launch,
    QuestionCategory.animals: Icons.pets,
    QuestionCategory.history: Icons.history_edu,
    QuestionCategory.science: Icons.science,
    QuestionCategory.geography: Icons.public,
  };

  static const categoryLabels = {
    QuestionCategory.space: 'Space',
    QuestionCategory.animals: 'Animals',
    QuestionCategory.history: 'History',
    QuestionCategory.science: 'Science',
    QuestionCategory.geography: 'Geography',
  };

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<QuizBloc>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Choose a Category', style: TextStyle(color: AppColors.secondary)),
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
              'Pick a topic to quiz on!',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Harder questions reward more stamps.',
              style: TextStyle(fontSize: 16.sp, color: Colors.white54),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: GridView.builder(
                itemCount: QuestionCategory.values.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 3.w,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final category = QuestionCategory.values[index];
                  final color = categoryColors[category]!;
                  final icon = categoryIcons[category]!;
                  final label = categoryLabels[category]!;
                  final count = bloc.questionCountForCategory(category);

                  return GestureDetector(
                    onTap: () {
                      bloc.add(QuizSelectCategory(category: category));
                      _log.i('→ QuizScreen ($label)');
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 10.h, color: color),
                          SizedBox(height: 1.h),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '$count questions',
                            style: TextStyle(fontSize: 14.sp, color: Colors.white54),
                          ),
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
