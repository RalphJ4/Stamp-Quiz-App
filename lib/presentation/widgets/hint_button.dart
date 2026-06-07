import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HintButton extends StatelessWidget {
  const HintButton({super.key});

  void _onTap(BuildContext context) {
    final state = context.read<QuizBloc>().state;
    if (state.hintsRemaining > 0) {
      context.read<QuizBloc>().add(QuizUseHint());
      ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar());
    }
  }

  SnackBar _buildSnackBar() {
    return SnackBar(
      content: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: const Color(0xFFE8B86D), size: 5.w),
          SizedBox(width: 2.w),
          Text(
            'Hint used! \u20135 XP penalty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF7B2FBE), width: 1),
      ),
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizBloc, QuizState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => _onTap(context),
          child: TweenAnimationBuilder<double>(
            key: ValueKey('hint_${state.hintsRemaining}'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: _bounceSequence(value),
                child: child,
              );
            },
            child: Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: const Color(0xFFE8B86D), size: 5.h),
                  SizedBox(width: 1.5.w),
                  ...List.generate(3, (i) {
                    final earned = i < state.hintsRemaining;
                    return Container(
                      width: 2.5.w,
                      height: 2.5.w,
                      margin: EdgeInsets.symmetric(horizontal: 0.3.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: earned ? const Color(0xFFE8B86D) : Colors.transparent,
                        border: Border.all(
                          color: earned ? const Color(0xFFE8B86D) : Colors.white38,
                          width: 1.5,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _bounceSequence(double t) {
    if (t < 0.2) return 1.0 + (t / 0.2) * 0.4;
    if (t < 0.4) return 1.4 + ((t - 0.2) / 0.2) * -0.5;
    if (t < 0.6) return 0.9 + ((t - 0.4) / 0.2) * 0.15;
    if (t < 0.8) return 1.05 + ((t - 0.6) / 0.2) * -0.05;
    return 1.0;
  }
}
