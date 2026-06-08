import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';

final _log = Logger();

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';
    final formKey = GlobalKey<FormState>();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.error!), backgroundColor: Colors.red.shade800),
          );
          context.read<AuthBloc>().add(AuthClearError());
        } else if (authState.mode == AuthMode.loggedIn) {
          _log.i('\u2190 popUntil root \u2192 HomeScreen (signed in)');
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: Colors.white,
          title: const Text('Sign In'),
          toolbarHeight: 7.h,
        ),
        body: Padding(
          padding: EdgeInsets.all(5.w),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: 4.h),
                TextFormField(
                  initialValue: '',
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.email, color: AppColors.secondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: AppColors.secondary),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => email = value,
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  initialValue: '',
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.lock, color: AppColors.secondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: AppColors.secondary),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  obscureText: true,
                  onChanged: (value) => password = value,
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignInWithEmail(
                        email: email.trim(),
                        password: password,
                      ));
                    },
                    icon: const Icon(Icons.login),
                    label: Text('Sign In', style: TextStyle(fontSize: 18.sp)),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Text('or', style: TextStyle(color: Colors.white38, fontSize: 15.sp)),
                    ),
                    const Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignInWithGoogle());
                    },
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: Text('Sign in with Google', style: TextStyle(fontSize: 17.sp)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
