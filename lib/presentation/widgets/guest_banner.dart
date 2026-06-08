import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:quiz_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';

final _log = Logger();

class GuestBanner extends StatelessWidget {
  const GuestBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();
    if (!authBloc.state.isGuest) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        _log.i('→ OnboardingScreen (guest banner)');
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceDeepPurple.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            Icon(Icons.person_outline, color: AppColors.secondary, size: 5.w),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Guest Mode — Sign in to save your progress!',
                style: TextStyle(fontSize: 14.sp, color: AppColors.secondary),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.secondary, size: 4.w),
          ],
        ),
      ),
    );
  }
}
