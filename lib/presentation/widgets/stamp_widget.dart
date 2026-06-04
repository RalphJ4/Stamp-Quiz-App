import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StampWidget extends StatefulWidget {
  final bool isEarned;
  final Color? color;

  const StampWidget({super.key, required this.isEarned, this.color});

  @override
  StampWidgetState createState() => StampWidgetState();
}

class StampWidgetState extends State<StampWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    if (widget.isEarned) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant StampWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEarned && !oldWidget.isEarned) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isEarned ? (widget.color ?? const Color(0xFF7B2FBE)) : const Color(0xFF16213E);
    final borderColor = widget.isEarned ? (widget.color ?? const Color(0xFFE8B86D)) : Colors.white24;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(60),
            color: widget.isEarned ? null : bgColor,
            gradient: widget.isEarned
                ? RadialGradient(colors: [bgColor.withValues(alpha: 0.3), bgColor])
                : null,
            image: widget.isEarned ? const DecorationImage(image: AssetImage('assets/images/stamp.png')) : null,
          ),
        ),
      ),
    );
  }
}
