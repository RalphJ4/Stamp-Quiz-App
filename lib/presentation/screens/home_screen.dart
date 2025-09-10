import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/presentation/provider/quiz_provider.dart';
import 'package:quiz_app/presentation/screens/quiz_screen.dart';
import 'package:quiz_app/presentation/screens/stamp_card_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final total = quizProvider.questions.length;
    final earned = quizProvider.stamps;
    final percent = total > 0 ? earned / total : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(
        title: const Text('Stamp Quiz'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        toolbarHeight: 7.h,
      ),
      body: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 3.h),
            Text(
              'Welcome, Challenger!',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 22.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Collect all the stamps by answering quiz questions!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),

            Stack(
              alignment: Alignment.center,
              children: [
                LinearProgressIndicator(
                  value: percent,
                  minHeight: 2.2.h,
                  backgroundColor: Colors.deepPurple[100],
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                Text(
                  '$earned / $total Stamps',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            Expanded(child: StampCardScreen(earnedStamps: earned, totalStamps: total)),
            SizedBox(height: 2.h),

            if (earned == total && total > 0)
              Text(
                'You collected all stamps! Great job!',
                style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 18.sp),
                textAlign: TextAlign.center,
              )
            else
              Text(
                'Keep going to collect more stamps!',
                style: TextStyle(color: Colors.deepPurple[400], fontWeight: FontWeight.w600, fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 2.h),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                textStyle: TextStyle(fontSize: 18.sp),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
              },
              icon: const Icon(Icons.play_arrow, size: 28),
              label: Text('Start Quiz', style: TextStyle(fontSize: 18.sp)),
            ),
            SizedBox(height: 2.h),

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
