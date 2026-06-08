import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/domain/entities/question.dart';
import 'package:quiz_app/presentation/screens/daily_challenge/bloc/daily_challenge_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/category_selection_screen.dart';
import 'package:quiz_app/presentation/screens/daily_challenge/daily_challenge_screen.dart';
import 'package:quiz_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:quiz_app/presentation/screens/duel/duel_screen.dart';
import 'package:quiz_app/presentation/screens/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:quiz_app/presentation/screens/leaderboard/leaderboard_screen.dart';
import 'package:quiz_app/presentation/screens/power_up/shop_screen.dart';
import 'package:quiz_app/presentation/screens/profile/profile_screen.dart';
import 'package:quiz_app/presentation/widgets/guest_banner.dart';
import 'package:quiz_app/presentation/widgets/xp_streak_bar.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';

final _log = Logger();

const _avatarEmojis = ['\u{1F9B8}', '\u{1F9D9}', '\u{1F3F9}', '\u{2694}\u{FE0F}', '\u{1F409}', '\u{1F98A}', '\u{1F985}', '\u{1F43A}'];
const _avatarColors = [
  AppColors.primary,
  Color(0xFF42A5F5),
  Color(0xFF43A047),
  AppColors.secondary,
  Color(0xFFE53935),
  Color(0xFFFF9800),
  Color(0xFF795548),
  Color(0xFF9E9E9E),
];

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
    final authManager = context.watch<AuthBloc>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stamp Quiz', style: TextStyle(color: AppColors.secondary)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        toolbarHeight: 7.h,
        actions: [
          IconButton(
            icon: Icon(Icons.leaderboard, color: AppColors.secondary, size: 6.w),
            tooltip: 'Leaderboard',
            onPressed: () {
              context.read<LeaderboardBloc>().forceSync();
              _log.i('→ LeaderboardScreen');
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_bag, color: AppColors.secondary, size: 6.w),
            tooltip: 'Power-Up Shop',
            onPressed: () {
              _log.i('→ ShopScreen');
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
            },
          ),
          if (authManager.isLoggedIn)
            IconButton(
              icon: CircleAvatar(
                radius: 3.w,
                backgroundColor: _avatarColors[authManager.avatarIndex],
                child: Text(
                  _avatarEmojis[authManager.avatarIndex],
                  style: TextStyle(fontSize: 4.w),
                ),
              ),
              tooltip: 'Profile',
              onPressed: () {
                _log.i('→ ProfileScreen');
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            )
          else
            IconButton(
              icon: Icon(Icons.login, color: AppColors.secondary, size: 6.w),
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
                  color: AppColors.secondary,
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

              GestureDetector(
                onTap: () {
                  _log.i('→ DuelScreen');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DuelScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sports_esports,
                          color: AppColors.secondary, size: 6.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duel Mode',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              'Challenge a friend in real-time!',
                              style: TextStyle(
                                  fontSize: 13.sp, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'FIGHT',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              const XpStreakBar(),
              SizedBox(height: 2.h),

              BlocBuilder<DailyChallengeBloc, DailyChallengeState>(
                builder: (context, dailyState) {
                  if (dailyState.loading) return const SizedBox.shrink();
                  final available = !dailyState.completed && dailyState.challenge != null;
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
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: available
                                ? [AppColors.primary, const Color(0xFF3D0D6B)]
                                : [AppColors.surfaceDark, AppColors.surface],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: available ? AppColors.secondary : Colors.white38,
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
                                        ? '${dailyState.challenge!.questions.length} questions — 3× stamps!'
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
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'PLAY',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.background,
                                  ),
                                ),
                              )
                            else
                              Icon(Icons.check_circle, color: Colors.green, size: 5.w),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categories',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
              ),
              SizedBox(height: 1.h),

              Wrap(
                spacing: 2.w,
                runSpacing: 1.5.h,
                children: QuestionCategory.values.map((cat) {
                  final color = categoryColors[cat]!;
                  final icon = categoryIcons[cat]!;
                  final label = categoryLabels[cat]!;
                  final catQuestions = context.read<QuizBloc>().questionCountForCategory(cat);

                  return SizedBox(
                    width: (100.w - 3.w * 2 - 2.w) / 2,
                    child: GestureDetector(
                      onTap: () {
                        _log.i('→ CategorySelectionScreen ($label)');
                        context.read<QuizBloc>().add(QuizSelectCategory(category: cat));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(icon, color: color, size: 7.w),
                            SizedBox(height: 0.5.h),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              '$catQuestions questions',
                              style: TextStyle(fontSize: 11.sp, color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 2.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
