import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final _log = Logger();

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';
    String confirmPassword = '';
    final formKey = GlobalKey<FormState>();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.error!), backgroundColor: Colors.red.shade800),
          );
          context.read<AuthBloc>().add(AuthClearError());
        } else if (authState.mode == AuthMode.loggedIn) {
          _log.i('\u2190 popUntil root \u2192 HomeScreen (registered)');
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          title: const Text('Register'),
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
                    prefixIcon: const Icon(Icons.email, color: Color(0xFFE8B86D)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Color(0xFFE8B86D)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1A1A2E),
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
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFFE8B86D)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Color(0xFFE8B86D)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1A1A2E),
                  ),
                  obscureText: true,
                  onChanged: (value) => password = value,
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  initialValue: '',
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFE8B86D)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Color(0xFFE8B86D)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1A1A2E),
                  ),
                  obscureText: true,
                  onChanged: (value) => confirmPassword = value,
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2FBE),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (password != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (password.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      context.read<AuthBloc>().add(AuthRegisterWithEmail(
                        email: email.trim(),
                        password: password,
                      ));
                    },
                    icon: const Icon(Icons.person_add),
                    label: Text('Register', style: TextStyle(fontSize: 18.sp)),
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
