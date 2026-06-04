import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../provider/daily_challenge_provider.dart';
import '../../domain/entities/question.dart';

final _log = Logger();

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyChallengeProvider>().loadToday();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _diffColor(QuestionDifficulty d) {
    switch (d) {
      case QuestionDifficulty.easy: return Colors.green;
      case QuestionDifficulty.medium: return Colors.orange;
      case QuestionDifficulty.hard: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyChallengeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D1A),
          appBar: AppBar(
            title: const Text('Daily Challenge'),
            centerTitle: true,
            backgroundColor: const Color(0xFF1A1A2E),
            foregroundColor: Colors.white,
            toolbarHeight: 7.h,
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(DailyChallengeProvider provider) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE8B86D)));
    }

    if (provider.completed) {
      return _buildCompleted(provider);
    }

    final question = provider.currentQuestion;
    if (question == null) {
      return const Center(child: Text('No challenge available', style: TextStyle(color: Colors.white70)));
    }

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (provider.currentIndex + 1) / (provider.challenge?.questions.length ?? 5),
            backgroundColor: const Color(0xFF16213E),
            color: const Color(0xFFE8B86D),
            minHeight: 1.5.h,
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Question ${provider.currentIndex + 1} of ${provider.challenge?.questions.length ?? 5}',
            style: TextStyle(fontSize: 15.sp, color: Colors.white70),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _diffColor(question.difficulty).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _diffColor(question.difficulty)),
                ),
                child: Text(
                  '${question.difficulty.name.toUpperCase()}  ×${question.stampReward * 3}',
                  style: TextStyle(
                    color: _diffColor(question.difficulty),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Card(
            color: const Color(0xFF1A1A2E),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                question.question,
                style: TextStyle(fontSize: 17.sp, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          ...List.generate(question.options.length, (i) {
            final isSelected = provider.selectedOption == i;
            Color? tileColor;
            if (provider.answered) {
              if (i == question.correctIndex) {
                tileColor = Colors.green.withValues(alpha: 0.2);
              } else if (isSelected) {
                tileColor = Colors.red.withValues(alpha: 0.2);
              }
            }
            return Card(
              color: tileColor ?? const Color(0xFF16213E),
              elevation: isSelected ? 6 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: tileColor ?? (isSelected ? const Color(0xFFE8B86D) : Colors.white24),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                title: Text(
                  question.options[i],
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: provider.answered
                        ? (i == question.correctIndex ? Colors.green[300]
                            : isSelected ? Colors.red[300]
                            : Colors.white70)
                        : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: provider.answered ? null : () => provider.selectOption(i),
              ),
            );
          }),
          const Spacer(),
          if (provider.answered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8B86D),
                  foregroundColor: const Color(0xFF0D0D1A),
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  _log.i('→ next daily question');
                  provider.nextQuestion();
                },
                label: Text(provider.currentIndex < (provider.challenge?.questions.length ?? 5) - 1
                    ? 'Next'
                    : 'Complete Challenge'),
              ),
            ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildCompleted(DailyChallengeProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 20.h, color: const Color(0xFFE8B86D)),
            SizedBox(height: 2.h),
            Text(
              'Challenge Complete!',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE8B86D),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              '${provider.correctCount}/${provider.challenge?.questions.length ?? 5} correct',
              style: TextStyle(fontSize: 18.sp, color: Colors.white70),
            ),
            SizedBox(height: 0.5.h),
            Text(
              '🔥 ${provider.dailyStreak}-day streak',
              style: TextStyle(fontSize: 16.sp, color: Colors.orange),
            ),
            if (provider.dailyStreak >= 7)
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8B86D).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8B86D)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.military_tech, color: Color(0xFFE8B86D), size: 20),
                      SizedBox(width: 2.w),
                      Text(
                        'Daily Devotee Badge',
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFFE8B86D), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 3.h),
            Text(
              'Next challenge in',
              style: TextStyle(fontSize: 15.sp, color: Colors.white54),
            ),
            SizedBox(height: 0.5.h),
            Text(
              provider.timeUntilReset,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _log.i('← pop daily challenge');
                Navigator.of(context).pop();
              },
              label: Text('Back to Home', style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }
}
