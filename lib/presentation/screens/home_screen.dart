import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/domain/entities/question.dart';
import 'package:quiz_app/presentation/provider/daily_challenge_provider.dart';
import 'package:quiz_app/presentation/provider/quiz_provider.dart';
import 'package:quiz_app/presentation/screens/category_selection_screen.dart';
import 'package:quiz_app/presentation/screens/daily_challenge_screen.dart';
import 'package:quiz_app/presentation/screens/onboarding_screen.dart';
import 'package:quiz_app/presentation/widgets/guest_banner.dart';
import 'package:quiz_app/services/auth_mode_manager.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final _log = Logger();

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
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Stamp Quiz', style: TextStyle(color: Color(0xFFE8B86D))),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        toolbarHeight: 7.h,
        actions: [
          if (authManager.isLoggedIn)
            PopupMenuButton<String>(
              icon: CircleAvatar(
                radius: 3.w,
                backgroundColor: const Color(0xFF7B2FBE),
                child: Icon(Icons.person, color: Colors.white, size: 5.w),
              ),
              onSelected: (value) {
                if (value == 'signout') authManager.signOut();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(authManager.user?.email ?? authManager.user?.name ?? 'User', style: const TextStyle(color: Colors.white70)),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'signout', child: Text('Sign Out', style: TextStyle(color: Colors.white))),
              ],
            )
          else
            IconButton(
              icon: Icon(Icons.login, color: const Color(0xFFE8B86D), size: 6.w),
              tooltip: 'Sign in',
              onPressed: () {
                _log.i('→ OnboardingScreen (sign in)');
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(3.w),
        child: SingleChildScrollView(
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
                  color: const Color(0xFFE8B86D),
                  fontSize: 22.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Collect stamps by answering quiz questions!',
                style: TextStyle(fontSize: 16.sp, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),

              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Stamps', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B2FBE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$earned',
                            style: TextStyle(color: const Color(0xFFE8B86D), fontWeight: FontWeight.bold, fontSize: 18.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    if (quizProvider.totalAnswered > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Accuracy', style: TextStyle(fontSize: 15.sp, color: Colors.white54)),
                          Text(
                            '${(quizProvider.totalCorrect / quizProvider.totalAnswered * 100).toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Best Streak', style: TextStyle(fontSize: 15.sp, color: Colors.white54)),
                          Row(
                            children: [
                              Icon(Icons.local_fire_department, color: const Color(0xFFE8B86D), size: 18.sp),
                              SizedBox(width: 1.w),
                              Text(
                                '${quizProvider.bestStreak}',
                                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white),
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

              Consumer<DailyChallengeProvider>(
                builder: (context, dailyProvider, _) {
                  if (dailyProvider.loading) return const SizedBox.shrink();
                  final available = !dailyProvider.completed && dailyProvider.challenge != null;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: GestureDetector(
                      onTap: () {
                        _log.i('→ DailyChallengeScreen');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                        );
                      },
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: available ? 1.05 : 1.0),
                        duration: const Duration(milliseconds: 1200),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 1.5.h),
                              
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: available
                                      ? [const Color(0xFF7B2FBE), const Color(0xFF3D0D6B)]
                                      : [const Color(0xFF16213E), const Color(0xFF1A1A2E)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: available ? const Color(0xFFE8B86D) : Colors.white38,
                                    size: 6.w,
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Daily Challenge',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: available ? Colors.white : Colors.white54,
                                          ),
                                        ),
                                        SizedBox(height: 0.3.h),
                                        Text(
                                          available
                                              ? '${dailyProvider.challenge!.questions.length} questions — 3× stamps!'
                                              : 'Completed — come back tomorrow!',
                                          style: TextStyle(fontSize: 13.sp, color: Colors.white54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (available)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8B86D),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'PLAY',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0D0D1A),
                                        ),
                                      ),
                                    )
                                  else
                                    Icon(Icons.check_circle, color: Colors.green, size: 5.w),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categories',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFFE8B86D)),
                ),
              ),
              SizedBox(height: 1.h),

              ...QuestionCategory.values.map((cat) {
                final color = categoryColors[cat]!;
                final icon = categoryIcons[cat]!;
                final label = categoryLabels[cat]!;
                final catQuestions = quizProvider.questionCountForCategory(cat);

                return Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: GestureDetector(
                    onTap: () {
                      _log.i('→ CategorySelectionScreen ($label)');
                      quizProvider.selectCategory(cat);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
                      );
                    },
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
                                  style: TextStyle(fontSize: 13.sp, color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(height: 2.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2FBE),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  onPressed: () {
                    _log.i('→ CategorySelectionScreen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: Text('Start Quiz', style: TextStyle(fontSize: 18.sp)),
                ),
              ),
              SizedBox(height: 1.h),

              TextButton(
                onPressed: () => quizProvider.resetQuiz(),
                child: Text('Reset Progress', style: TextStyle(fontSize: 16.sp, color: Colors.white54)),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
