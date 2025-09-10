import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/presentation/provider/quiz_provider.dart';
import 'package:confetti/confetti.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 1));

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showStampDialog(BuildContext context) {
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Stack(
            alignment: Alignment.center,
            children: [
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.08,
                numberOfParticles: 40,
                maxBlastForce: 25,
                minBlastForce: 10,
                gravity: 0.18,
              ),
              AlertDialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder:
                          (context, scale, child) => Transform.scale(
                            scale: scale,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.amber, blurRadius: 40, spreadRadius: 12)],
                                border: Border.all(color: Colors.deepPurple, width: 3),
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage('assets/images/stamp.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              width: 38.w,
                              height: 38.w,
                            ),
                          ),
                      child: const SizedBox.shrink(),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'You Earned a Stamp!',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 19.sp,
                        shadows: [Shadow(color: Colors.white, blurRadius: 10, offset: Offset(0, 0))],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    IconButton(
                      icon: Icon(Icons.check_circle, color: Colors.green, size: 7.h),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      tooltip: 'Continue',
                    ),
                  ],
                ),
                actions: const [],
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 22.sp),
            SizedBox(width: 2.w),
            Text('Quiz', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        toolbarHeight: 7.h,
        backgroundColor: Colors.deepPurple,
        elevation: 2,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          if (provider.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final question = provider.questions[provider.currentIndex];

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (provider.currentIndex + 1) / provider.questions.length,
                        minHeight: 2.2.h,
                        backgroundColor: Colors.deepPurple[100],
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars, color: Colors.amber[800], size: 16.sp),
                          SizedBox(width: 1.w),
                          Text(
                            'Level ${(provider.currentIndex + 1)}',
                            style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.bold, fontSize: 15.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'Question ${provider.currentIndex + 1}/${provider.questions.length}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp, color: Colors.deepPurple),
                ),
                SizedBox(height: 1.5.h),
                Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Text(
                      question.question,
                      style: TextStyle(fontSize: 18.sp, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                ...List.generate(question.options.length, (i) {
                  final isSelected = provider.selectedOption == i;
                  Color? tileColor;
                  if (provider.answered) {
                    if (i == question.correctIndex) {
                      tileColor = Colors.green[100];
                    } else if (isSelected) {
                      tileColor = Colors.red[100];
                    }
                  }
                  return Card(
                    elevation: isSelected ? 6 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side:
                          isSelected
                              ? BorderSide(color: Colors.deepPurple, width: 2)
                              : BorderSide(color: Colors.grey[300]!),
                    ),
                    child: ListTile(
                      tileColor: tileColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text(
                        question.options[i],
                        style: TextStyle(
                          fontSize: 16.5.sp,
                          color:
                              provider.answered
                                  ? (i == question.correctIndex
                                      ? Colors.green[900]
                                      : isSelected
                                      ? Colors.red[900]
                                      : Colors.black87)
                                  : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap:
                          provider.answered
                              ? null
                              : () {
                                provider.selectOption(i);
                                if (question.correctIndex == i) {
                                  _showStampDialog(context);
                                }
                              },
                      trailing:
                          provider.answered
                              ? (i == question.correctIndex
                                  ? Icon(Icons.check_circle, color: Colors.green, size: 20.sp)
                                  : isSelected
                                  ? Icon(Icons.cancel, color: Colors.red, size: 20.sp)
                                  : null)
                              : null,
                    ),
                  );
                }),
                SizedBox(height: 2.5.h),
                if (provider.answered)
                  Row(
                    children: [
                      if (provider.currentIndex < provider.questions.length - 1)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.5.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: TextStyle(fontSize: 16.sp),
                            elevation: 3,
                          ),
                          icon: Icon(Icons.arrow_forward, size: 18.sp),
                          onPressed: () => provider.nextQuestion(),
                          label: const Text('Next'),
                        ),
                      SizedBox(width: 3.w),
                      if (provider.currentIndex == provider.questions.length - 1)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.5.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: TextStyle(fontSize: 16.sp),
                            elevation: 3,
                          ),
                          icon: Icon(Icons.emoji_events, size: 18.sp),
                          onPressed: () => Navigator.of(context).pop(),
                          label: const Text('Finish'),
                        ),
                    ],
                  )
                else
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      'Select an answer to submit.',
                      style: TextStyle(fontSize: 15.sp, color: Colors.deepPurple),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
