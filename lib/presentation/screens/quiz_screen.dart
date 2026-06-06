import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/domain/entities/power_up.dart';
import 'package:quiz_app/domain/entities/question.dart';
import 'package:quiz_app/presentation/provider/quiz_provider.dart';
import 'package:quiz_app/presentation/provider/power_up_provider.dart';
import 'package:quiz_app/presentation/widgets/hint_button.dart';
import 'package:confetti/confetti.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final _log = Logger();

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  bool _timerAutoPopped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<QuizProvider>().startTimer();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showStampDialog(BuildContext context) {
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Stack(
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
            backgroundColor: const Color(0xFF1A1A2E),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0xFFE8B86D), blurRadius: 40, spreadRadius: 12)],
                        border: Border.all(color: const Color(0xFF7B2FBE), width: 3),
                        color: Colors.white,
                        image: const DecorationImage(
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
                    color: const Color(0xFFE8B86D),
                    fontWeight: FontWeight.bold,
                    fontSize: 19.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                IconButton(
                  icon: Icon(Icons.check_circle, color: const Color(0xFFE8B86D), size: 7.h),
                  onPressed: () {
                    _log.i('← pop stamp dialog');
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
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: const Color(0xFFE8B86D), size: 22.sp),
            SizedBox(width: 2.w),
            Text('Quiz', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          Consumer<PowerUpProvider>(
            builder: (context, pu, _) {
              if (!pu.hasActiveEffects) return const HintButton();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...PowerUpType.values.where((t) => pu.hasEffect(t)).map((t) {
                    return Padding(
                      padding: EdgeInsets.only(right: 1.5.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
                        decoration: BoxDecoration(
                          color: t.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: t.color, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(t.icon, color: t.color, size: 14.sp),
                            SizedBox(width: 0.5.w),
                            Text(
                              t == PowerUpType.skipQuestion ? 'Skip' : '2×',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: t.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const HintButton(),
                ],
              );
            },
          ),
        ],
        toolbarHeight: 7.h,
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 2,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          if (provider.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE8B86D)));
          }

          if (provider.isQuizFinished && !_timerAutoPopped) {
            _timerAutoPopped = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop();
            });
          }

          final question = provider.questions[provider.currentIndex];
          final diffColors = {
            QuestionDifficulty.easy: Colors.green,
            QuestionDifficulty.medium: Colors.orange,
            QuestionDifficulty.hard: Colors.red,
          };
          final diffLabels = {
            QuestionDifficulty.easy: 'Easy',
            QuestionDifficulty.medium: 'Medium',
            QuestionDifficulty.hard: 'Hard',
          };
          final diffColor = diffColors[question.difficulty]!;
          final diffLabel = diffLabels[question.difficulty]!;

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
                        backgroundColor: const Color(0xFF16213E),
                        color: const Color(0xFFE8B86D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B2FBE).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF7B2FBE), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars, color: const Color(0xFFE8B86D), size: 16.sp),
                          SizedBox(width: 1.w),
                          Text(
                            'Level ${(provider.currentIndex + 1)}',
                            style: TextStyle(color: const Color(0xFFE8B86D), fontWeight: FontWeight.bold, fontSize: 15.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.8.h),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: provider.remainingSeconds <= 10 ? Colors.red : const Color(0xFFE8B86D),
                      size: 16.sp,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${provider.remainingSeconds}s',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: provider.remainingSeconds <= 10 ? Colors.red : const Color(0xFFE8B86D),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Question ${provider.currentIndex + 1}/${provider.questions.length}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp, color: Colors.white70),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: diffColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: diffColor),
                      ),
                      child: Text(
                        '$diffLabel  +${question.stampReward}',
                        style: TextStyle(
                          color: diffColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                Card(
                  elevation: 2,
                  color: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Text(
                      question.question,
                      style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Consumer<PowerUpProvider>(
                  builder: (context, pu, _) {
                    final owned = PowerUpType.values.where((t) => pu.countOf(t) > 0 || pu.hasEffect(t)).toList();
                    if (owned.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: SizedBox(
                        height: 5.5.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: owned.length,
                          separatorBuilder: (_, __) => SizedBox(width: 2.w),
                          itemBuilder: (context, i) {
                            final type = owned[i];
                            final active = pu.hasEffect(type);
                            final count = pu.countOf(type);
                            return GestureDetector(
                              onTap: active ? null : () {
                                final err = pu.activatePowerUp(type);
                                if (err != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(err), backgroundColor: Colors.red.shade800),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${type.label} activated!'),
                                      backgroundColor: const Color(0xFF7B2FBE),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                decoration: BoxDecoration(
                                  color: active
                                      ? type.color.withValues(alpha: 0.25)
                                      : const Color(0xFF1A1A2E),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: active ? type.color : Colors.white24,
                                    width: active ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(type.icon, color: type.color, size: 4.5.w),
                                    SizedBox(width: 1.w),
                                    Text(
                                      type.label,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: active ? type.color : Colors.white70,
                                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    if (active)
                                      Text(
                                        ' active',
                                        style: TextStyle(fontSize: 10.sp, color: Colors.green[300]),
                                      ),
                                    if (!active)
                                      Text(
                                        ' ×$count',
                                        style: TextStyle(fontSize: 11.sp, color: Colors.white38),
                                      ),
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
                ...List.generate(question.options.length, (i) {
                  final isSelected = provider.selectedOption == i;
                  final isEliminated = provider.eliminatedOptions.contains(i) && !provider.answered;
                  Color? tileColor;
                  if (provider.answered) {
                    if (i == question.correctIndex) {
                      tileColor = Colors.green.withValues(alpha: 0.2);
                    } else if (isSelected) {
                      tileColor = Colors.red.withValues(alpha: 0.2);
                    }
                  } else if (isEliminated) {
                    tileColor = Colors.white10;
                  }
                  return Card(
                    elevation: isSelected ? 6 : 2,
                    color: tileColor ?? const Color(0xFF16213E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: tileColor ?? (isSelected ? const Color(0xFFE8B86D) : isEliminated ? Colors.white10 : Colors.white24),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      tileColor: tileColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text(
                        question.options[i],
                        style: TextStyle(
                          fontSize: 16.5.sp,
                          color: isEliminated
                              ? Colors.white24
                              : (provider.answered
                                  ? (i == question.correctIndex ? Colors.green[300]
                                      : isSelected ? Colors.red[300]
                                      : Colors.white70)
                                  : Colors.white),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          decoration: isEliminated ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      onTap: (provider.answered || isEliminated) ? null : () {
                        provider.selectOption(i);
                        if (question.correctIndex == i) {
                          _showStampDialog(context);
                        }
                      },
                      trailing: provider.answered
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
                            backgroundColor: const Color(0xFF7B2FBE),
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
                            backgroundColor: const Color(0xFF7B2FBE),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.5.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: TextStyle(fontSize: 16.sp),
                            elevation: 3,
                          ),
                          icon: Icon(Icons.emoji_events, size: 18.sp, color: const Color(0xFFE8B86D)),
                          onPressed: () {
                            provider.finishQuiz();
                            _log.i('← pop QuizScreen (finished)');
                            Navigator.of(context).pop();
                          },
                          label: const Text('Finish'),
                        ),
                    ],
                  )
                else
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      'Select an answer to submit.',
                      style: TextStyle(fontSize: 15.sp, color: Colors.white54),
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
