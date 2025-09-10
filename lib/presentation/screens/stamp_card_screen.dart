import 'package:flutter/material.dart';
import 'package:quiz_app/presentation/widgets/stamp_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StampCardScreen extends StatelessWidget {
  final int earnedStamps;
  final int totalStamps;

  const StampCardScreen({super.key, required this.earnedStamps, required this.totalStamps});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15.h,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: totalStamps,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2.w,
          mainAxisSpacing: 2.w,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return StampWidget(key: ValueKey(index), isEarned: index < earnedStamps);
        },
      ),
    );
  }
}
