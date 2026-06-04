import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/presentation/provider/quiz_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HintButton extends StatefulWidget {
  const HintButton({super.key});

  @override
  State<HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<HintButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: 0.0), weight: 1),
    ]).animate(_controller);

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 2),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(QuizProvider provider) {
    if (provider.hintsRemaining > 0) {
      provider.useHint();
      if (_controller.isAnimating) _controller.reset();
      _controller.forward();
      ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar());
    } else {
      if (_controller.isAnimating) _controller.reset();
      _controller.forward();
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
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: () => _onTap(provider),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final isShaking = provider.hintsRemaining == 0 && _controller.isAnimating;
              final isBouncing = provider.hintsRemaining > 0 && _controller.isAnimating;

              return Transform.translate(
                offset: Offset(isShaking ? _shakeAnimation.value : 0, 0),
                child: Transform.scale(
                  scale: isBouncing ? _bounceAnimation.value : 1.0,
                  child: child,
                ),
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
                    final earned = i < provider.hintsRemaining;
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
}
