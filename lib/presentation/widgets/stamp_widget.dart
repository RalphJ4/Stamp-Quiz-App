import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';

class StampWidget extends StatelessWidget {
  final bool isEarned;
  final Color? color;

  const StampWidget({super.key, required this.isEarned, this.color});

  @override
  Widget build(BuildContext context) {
    final bgColor = isEarned ? (color ?? AppColors.primary) : AppColors.surfaceDark;
    final borderColor = isEarned ? (color ?? AppColors.secondary) : Colors.white24;

    final container = Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(60),
        color: isEarned ? null : bgColor,
        gradient: isEarned
            ? RadialGradient(colors: [bgColor.withValues(alpha: 0.3), bgColor])
            : null,
        image: isEarned
            ? const DecorationImage(image: AssetImage('assets/images/stamp.png'))
            : null,
      ),
    );

    if (!isEarned) {
      return Opacity(
        opacity: 0,
        child: Transform.scale(
          scale: 0.5,
          child: container,
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('stamp_$isEarned'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: container,
    );
  }
}
