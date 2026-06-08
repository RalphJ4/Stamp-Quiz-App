import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/login_screen.dart';
import 'package:quiz_app/presentation/screens/auth/register_screen.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final _log = Logger();

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(Icons.collections_bookmark, size: 25.h, color: AppColors.secondary),
              SizedBox(height: 3.h),
              Text(
                'Stamp Quiz',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Collect stamps, test your knowledge!',
                style: TextStyle(fontSize: 16.sp, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  onPressed: () {
                    _log.i('→ LoginScreen');
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  icon: const Icon(Icons.login, size: 22),
                  label: Text('Sign In', style: TextStyle(fontSize: 18.sp)),
                ),
              ),
              SizedBox(height: 1.5.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _log.i('→ RegisterScreen');
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  icon: const Icon(Icons.person_add, size: 22),
                  label: Text('Register', style: TextStyle(fontSize: 18.sp)),
                ),
              ),
              SizedBox(height: 1.5.h),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white54,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                  onPressed: () {
                    final auth = context.read<AuthBloc>();
                    if (auth.state.mode == AuthMode.none) {
                      _log.i('auth.none → startGuestSession + popUntil');
                      auth.add(AuthStartGuestSession());
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      _log.i('← popUntil root');
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  icon: Icon(Icons.person_outline, size: 22),
                  label: Text('Continue as Guest', style: TextStyle(fontSize: 17.sp)),
                ),
              ),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }
}

