import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/services/auth_mode_manager.dart';
import 'package:quiz_app/presentation/screens/onboarding_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GuestBanner extends StatelessWidget {
  const GuestBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<AuthModeManager>();
    if (!manager.isGuest) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.person_outline, color: Colors.amber[800], size: 5.w),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Guest Mode — Sign in to save your progress!',
                style: TextStyle(fontSize: 14.sp, color: Colors.amber[900]),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.amber[800], size: 4.w),
          ],
        ),
      ),
    );
  }
}
