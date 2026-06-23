import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizBloc, QuizState>(
      builder: (context, state) {
        final questions = state.questions;
        final answers = state.userAnswers;
        int correct = 0;
        final wrongList = <MapEntry<int, int?>>[];

        for (int i = 0; i < questions.length; i++) {
          final selected = i < answers.length ? answers[i] : null;
          if (selected != null && selected == questions[i].correctIndex) {
            correct++;
          } else {
            wrongList.add(MapEntry(i, selected));
          }
        }

        final total = questions.length;
        final pct = total > 0 ? (correct / total * 100).round() : 0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Results', style: TextStyle(color: AppColors.secondary)),
            centerTitle: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            toolbarHeight: 7.h,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                SizedBox(height: 2.h),
                Container(
                  width: 100.w,
                  padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$correct / $total',
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: correct == total ? AppColors.secondary : Colors.white,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: pct >= 70 ? AppColors.statCorrect : AppColors.statAccuracy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      LinearProgressIndicator(
                        value: total > 0 ? correct / total : 0,
                        minHeight: 1.5.h,
                        backgroundColor: AppColors.surfaceDark,
                        color: correct == total ? AppColors.secondary : AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                if (wrongList.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Column(
                      children: [
                        Icon(Icons.emoji_events, size: 20.w, color: AppColors.secondary),
                        SizedBox(height: 2.h),
                        Text(
                          'Perfect Score!',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.red[300], size: 5.w),
                      SizedBox(width: 2.w),
                      Text(
                        'Review Wrong Answers',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  ...wrongList.map((entry) {
                    final qIdx = entry.key;
                    final selected = entry.value;
                    final question = questions[qIdx];
                    final correctAnswer = question.options[question.correctIndex];
                    final userAnswer = selected != null && selected < question.options.length
                        ? question.options[selected]
                        : null;

                    return Container(
                      width: 100.w,
                      margin: EdgeInsets.only(bottom: 1.5.h),
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Q${qIdx + 1}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.red[300],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                selected == null ? 'Timed out' : 'Wrong',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.red[300],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            question.question,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          if (userAnswer != null)
                            _answerRow(Icons.close, 'Your answer', userAnswer, Colors.red[300]!),
                          if (userAnswer != null)
                            SizedBox(height: 0.5.h),
                          _answerRow(Icons.check_circle, 'Correct answer', correctAnswer, Colors.green[300]!),
                        ],
                      ),
                    );
                  }),
                ],
                SizedBox(height: 3.h),
                SizedBox(
                  width: 100.w,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: TextStyle(fontSize: 17.sp),
                    ),
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    label: const Text('Back to Home'),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _answerRow(IconData icon, String label, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 4.5.w),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: Colors.white54),
              ),
              SizedBox(height: 0.2.h),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
