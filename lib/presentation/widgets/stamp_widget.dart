import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StampWidget extends StatefulWidget {
  final bool isEarned;

  const StampWidget({super.key, required this.isEarned});

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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(60),
            color: Colors.grey[200],
            image: widget.isEarned ? const DecorationImage(image: AssetImage('assets/images/stamp.png')) : null,
          ),
        ),
      ),
    );
  }
}
