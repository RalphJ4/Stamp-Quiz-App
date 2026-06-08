import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/domain/entities/power_up.dart';
import 'package:quiz_app/domain/entities/question.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/power_up/bloc/power_up_bloc.dart';
import 'package:quiz_app/presentation/widgets/hint_button.dart';
import 'package:confetti/confetti.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';

final _log = Logger();

class _QuizAutoPop extends StatelessWidget {
  const _QuizAutoPop();

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizBloc, QuizState>(
      listenWhen: (prev, curr) => !prev.isQuizFinished && curr.isQuizFinished,
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) Navigator.of(context).pop();
        });
      },
      child: const SizedBox.shrink(),
    );
  }
}

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  void _showStampDialog(BuildContext context) {
    final controller = ConfettiController(duration: const Duration(seconds: 1));
    controller.play();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.08,
            numberOfParticles: 40,
            maxBlastForce: 25,
            minBlastForce: 10,
            gravity: 0.18,
          ),
          AlertDialog(
            backgroundColor: AppColors.surface,
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
                        boxShadow: [BoxShadow(color: AppColors.secondary, blurRadius: 40, spreadRadius: 12)],
                        border: Border.all(color: AppColors.primary, width: 3),
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
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 19.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                IconButton(
                  icon: Icon(Icons.check_circle, color: AppColors.secondary, size: 7.h),
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
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: AppColors.secondary, size: 22.sp),
            SizedBox(width: 2.w),
            Text('Quiz', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          BlocBuilder<PowerUpBloc, PowerUpState>(
            builder: (context, state) {
              if (!state.hasActiveEffects) return const HintButton();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...PowerUpType.values.where((t) => state.hasEffect(t)).map((t) {
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
        backgroundColor: AppColors.surface,
        elevation: 2,
      ),
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }

          final question = state.questions[state.currentIndex];
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

          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (state.currentIndex + 1) / state.questions.length,
                            minHeight: 2.2.h,
                            backgroundColor: AppColors.surfaceDark,
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary, width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.stars, color: AppColors.secondary, size: 16.sp),
                              SizedBox(width: 1.w),
                              Text(
                                'Level ${(state.currentIndex + 1)}',
                                style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 15.sp),
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
                          color: state.remainingSeconds <= 10 ? Colors.red : AppColors.secondary,
                          size: 16.sp,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${state.remainingSeconds}s',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: state.remainingSeconds <= 10 ? Colors.red : AppColors.secondary,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Question ${state.currentIndex + 1}/${state.questions.length}',
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
                      color: AppColors.surface,
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
                    BlocBuilder<PowerUpBloc, PowerUpState>(
                      builder: (context, puState) {
                        final owned = PowerUpType.values.where((t) => puState.countOf(t) > 0 || puState.hasEffect(t)).toList();
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
                                final active = puState.hasEffect(type);
                                final count = puState.countOf(type);
                                return GestureDetector(
                                  onTap: active ? null : () {
                                    context.read<PowerUpBloc>().add(PowerUpActivate(type: type));
                                    if (type == PowerUpType.timeFreeze) {
                                      context.read<QuizBloc>().add(QuizPauseTimer());
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${type.label} activated!'),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? type.color.withValues(alpha: 0.25)
                                          : AppColors.surface,
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
                      final isSelected = state.selectedOption == i;
                      final isEliminated = state.eliminatedOptions.contains(i) && !state.answered;
                      Color? tileColor;
                      Color borderColor = Colors.white24;
                      double borderWidth = 1;

                      if (state.answered) {
                        if (i == question.correctIndex) {
                          tileColor = Colors.green.withValues(alpha: 0.2);
                          borderColor = Colors.green.withValues(alpha: 0.6);
                        } else if (isSelected) {
                          tileColor = Colors.red.withValues(alpha: 0.2);
                          borderColor = Colors.red.withValues(alpha: 0.6);
                        } else {
                          borderColor = Colors.white24;
                        }
                      } else if (isEliminated) {
                        tileColor = Colors.white10;
                        borderColor = Colors.white10;
                      } else if (isSelected) {
                        borderColor = AppColors.secondary;
                        borderWidth = 2;
                      }

                      return Card(
                        elevation: isSelected && !state.answered ? 6 : 2,
                        color: tileColor ?? AppColors.surfaceDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: borderColor,
                            width: borderWidth,
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
                                  : (state.answered
                                      ? (i == question.correctIndex ? Colors.green[300]
                                          : isSelected ? Colors.red[300]
                                          : Colors.white70)
                                      : Colors.white),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              decoration: isEliminated ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          onTap: (state.answered || isEliminated) ? null : () {
                            context.read<QuizBloc>().add(QuizSelectOption(index: i));
                            if (context.read<PowerUpBloc>().state.hasEffect(PowerUpType.timeFreeze)) {
                              context.read<PowerUpBloc>().add(PowerUpConsumeEffect(type: PowerUpType.timeFreeze));
                            }
                            if (question.correctIndex == i) {
                              _showStampDialog(context);
                            }
                          },
                          trailing: state.answered
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
                    if (state.answered)
                      Row(
                        children: [
                          if (state.currentIndex < state.questions.length - 1)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.5.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: TextStyle(fontSize: 16.sp),
                                elevation: 3,
                              ),
                              icon: Icon(Icons.arrow_forward, size: 18.sp),
                              onPressed: () {
                                if (context.read<PowerUpBloc>().state.hasEffect(PowerUpType.timeFreeze)) {
                                  context.read<PowerUpBloc>().add(PowerUpConsumeEffect(type: PowerUpType.timeFreeze));
                                }
                                context.read<QuizBloc>().add(QuizNextQuestion());
                              },
                              label: const Text('Next'),
                            ),
                          SizedBox(width: 3.w),
                          if (state.currentIndex == state.questions.length - 1)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.5.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: TextStyle(fontSize: 16.sp),
                                elevation: 3,
                              ),
                              icon: Icon(Icons.emoji_events, size: 18.sp, color: AppColors.secondary),
                              onPressed: () {
                                context.read<QuizBloc>().add(QuizFinish());
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
              ),
              const _QuizAutoPop(),
            ],
          );
        },
      ),
    );
  }
}
