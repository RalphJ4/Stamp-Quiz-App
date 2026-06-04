import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/domain/entities/question.dart';
import 'package:quiz_app/presentation/provider/quiz_provider.dart';
import 'package:quiz_app/presentation/screens/category_selection_screen.dart';
import 'package:quiz_app/presentation/screens/onboarding_screen.dart';
import 'package:quiz_app/presentation/widgets/guest_banner.dart';
import 'package:quiz_app/services/auth_mode_manager.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    final quizProvider = Provider.of<QuizProvider>(context);
    final earned = quizProvider.stamps;

    final authManager = context.watch<AuthModeManager>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(
        title: const Text('Stamp Quiz'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        toolbarHeight: 7.h,
        actions: [
          if (authManager.isLoggedIn)
            PopupMenuButton<String>(
              icon: CircleAvatar(
                radius: 3.w,
                backgroundColor: Colors.deepPurple[300],
                child: Icon(Icons.person, color: Colors.white, size: 5.w),
              ),
              onSelected: (value) {
                if (value == 'signout') authManager.signOut();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(authManager.user?.email ?? authManager.user?.name ?? 'User'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'signout', child: Text('Sign Out')),
              ],
            )
          else
            IconButton(
              icon: Icon(Icons.login, color: Colors.amber[200], size: 6.w),
              tooltip: 'Sign in',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen())),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 1.h),
            const GuestBanner(),
            SizedBox(height: 1.5.h),
            Text(
              'Welcome, Challenger!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 22.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Collect stamps by answering quiz questions!',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),

            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Stamps', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$earned',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  if (quizProvider.totalAnswered > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Accuracy', style: TextStyle(fontSize: 15.sp, color: Colors.grey[600])),
                        Text(
                          '${(quizProvider.totalCorrect / quizProvider.totalAnswered * 100).toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Best Streak', style: TextStyle(fontSize: 15.sp, color: Colors.grey[600])),
                        Row(
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.orange, size: 18.sp),
                            SizedBox(width: 1.w),
                            Text(
                              '${quizProvider.bestStreak}',
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 2.h),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
            ),
            SizedBox(height: 1.h),

            ...QuestionCategory.values.map((cat) {
              final color = categoryColors[cat]!;
              final icon = categoryIcons[cat]!;
              final label = categoryLabels[cat]!;
              final catQuestions = quizProvider.questions.where((q) => q.category == cat).length;

              return Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 7.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              '$catQuestions questions available',
                              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Spacer(),

            Consumer<QuizProvider>(
              builder: (context, quizProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
                      );
                    },
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: Text('Start Quiz', style: TextStyle(fontSize: 18.sp)),
                  ),
                );
              },
            ),
            SizedBox(height: 1.h),

            TextButton(
              onPressed: () {
                quizProvider.resetQuiz();
              },
              child: Text('Reset Progress', style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }
}
