import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/services/auth_mode_manager.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final _log = Logger();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final manager = context.read<AuthModeManager>();
    final err = await manager.registerWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _error = err;
        _loading = false;
      });
    } else {
      _log.i('← popUntil root → HomeScreen (registered)');
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text('Register'),
        toolbarHeight: 7.h,
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            SizedBox(height: 4.h),
            TextField(
              controller: _emailController,
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
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _passwordController,
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
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _confirmController,
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
            ),
            if (_error != null) ...[
              SizedBox(height: 1.h),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
            ],
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
                onPressed: _loading ? null : _register,
                icon: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.person_add),
                label: Text('Register', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
