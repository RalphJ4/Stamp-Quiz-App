import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/domain/entities/power_up.dart';
import 'package:quiz_app/presentation/provider/power_up_provider.dart';
import 'package:quiz_app/presentation/provider/quiz_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class XpStreakBar extends StatelessWidget {
  const XpStreakBar({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final powerUpProvider = context.watch<PowerUpProvider>();
    final hasActiveEffects = powerUpProvider.hasActiveEffects;

    return Container(
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
              Text('Total Stamps',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B2FBE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${quizProvider.stamps}',
                  style: TextStyle(
                    color: const Color(0xFFE8B86D),
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          if (quizProvider.totalAnswered > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Accuracy',
                    style: TextStyle(fontSize: 15.sp, color: Colors.white54)),
                Text(
                  '${(quizProvider.totalCorrect / quizProvider.totalAnswered * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Best Streak',
                    style: TextStyle(fontSize: 15.sp, color: Colors.white54)),
                Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: const Color(0xFFE8B86D), size: 18.sp),
                    SizedBox(width: 1.w),
                    Text(
                      '${quizProvider.bestStreak}',
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ],
          if (hasActiveEffects) ...[
            SizedBox(height: 0.5.h),
            const Divider(color: Colors.white12),
            SizedBox(height: 0.5.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: powerUpProvider.activeEffects.entries
                  .where((e) => e.value > 0)
                  .map((entry) {
                final type = entry.key;
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: type.color, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon,
                          color: type.color, size: 4.5.w),
                      SizedBox(width: 1.w),
                      Text(
                        '${type.label} ×${entry.value}',
                        style: TextStyle(
                          color: type.color,
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
