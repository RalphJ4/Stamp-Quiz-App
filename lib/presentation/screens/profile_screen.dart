import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/services/auth_mode_manager.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _avatarColors = [
    Color(0xFF7B2FBE),
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFF9800),
    Color(0xFFE8B86D),
  ];

  late TextEditingController _nameController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  int _selectedColor = 0;
  bool _saving = false;
  bool _passwordSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthModeManager>();
    _nameController.text = auth.user?.name ?? '';
    final color = await auth.getAvatarColor();
    if (mounted) setState(() => _selectedColor = color);
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final auth = context.read<AuthModeManager>();
    final error = await auth.updateDisplayName(name);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Name updated!'),
          backgroundColor: error != null ? Colors.red.shade800 : const Color(0xFF7B2FBE),
        ),
      );
    }
  }

  Future<void> _saveColor(int index) async {
    setState(() => _selectedColor = index);
    final auth = context.read<AuthModeManager>();
    final error = await auth.updateAvatarColor(index);
    if (mounted && error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red.shade800),
      );
    }
  }

  Future<void> _savePassword() async {
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all fields'), backgroundColor: Colors.red),
      );
      return;
    }
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: Colors.red),
      );
      return;
    }
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _passwordSaving = true);
    final auth = context.read<AuthModeManager>();
    final error = await auth.updatePassword(current, newPass);
    if (mounted) {
      setState(() => _passwordSaving = false);
      if (error == null) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Password updated!'),
          backgroundColor: error != null ? Colors.red.shade800 : const Color(0xFF7B2FBE),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModeManager>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Color(0xFFE8B86D))),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A2E),
        toolbarHeight: 7.h,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 10.w,
              backgroundColor: _avatarColors[_selectedColor],
              child: Text(
                (auth.user?.name ?? auth.user?.email ?? '?')[0].toUpperCase(),
                style: TextStyle(fontSize: 10.w, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              auth.user?.name ?? 'Player',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              auth.user?.email ?? '',
              style: TextStyle(fontSize: 14.sp, color: Colors.white54),
            ),
            SizedBox(height: 3.h),

            _section('Avatar Colour'),
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_avatarColors.length, (i) {
                final selected = _selectedColor == i;
                return GestureDetector(
                  onTap: () => _saveColor(i),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                    width: 9.w,
                    height: 9.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _avatarColors[i],
                      border: Border.all(
                        color: selected ? const Color(0xFFE8B86D) : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: _avatarColors[i].withValues(alpha: 0.6), blurRadius: 12, spreadRadius: 2)]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }),
            ),
            SizedBox(height: 3.h),

            _section('Display Name'),
            SizedBox(height: 1.h),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Enter your name'),
            ),
            SizedBox(height: 1.5.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: _buttonStyle(),
                onPressed: _saving ? null : _saveName,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Name'),
              ),
            ),
            SizedBox(height: 3.h),

            if (auth.canChangePassword) ...[
              _section('Change Password'),
              SizedBox(height: 1.h),
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Current password'),
              ),
              SizedBox(height: 1.h),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('New password'),
              ),
              SizedBox(height: 1.h),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Confirm new password'),
              ),
              SizedBox(height: 1.5.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: _buttonStyle(),
                  onPressed: _passwordSaving ? null : _savePassword,
                  child: _passwordSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Update Password'),
                ),
              ),
            ],
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[300],
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: TextStyle(fontSize: 16.sp),
                ),
                icon: const Icon(Icons.logout, size: 20),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A2E),
                      title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                      content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('Sign Out', style: TextStyle(color: Colors.red[300])),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<AuthModeManager>().signOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                label: const Text('Sign Out'),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFFE8B86D)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF16213E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7B2FBE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF7B2FBE),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: TextStyle(fontSize: 16.sp),
    );
  }
}
