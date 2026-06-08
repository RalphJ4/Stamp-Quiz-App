import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class _AvatarPreset {
  final String name;
  final String emoji;
  final Color color;

  const _AvatarPreset({required this.name, required this.emoji, required this.color});
}

const _avatarPresets = [
  _AvatarPreset(name: 'Hero', emoji: '\u{1F9B8}', color: Color(0xFF7B2FBE)),
  _AvatarPreset(name: 'Wizard', emoji: '\u{1F9D9}', color: Color(0xFF42A5F5)),
  _AvatarPreset(name: 'Archer', emoji: '\u{1F3F9}', color: Color(0xFF43A047)),
  _AvatarPreset(name: 'Knight', emoji: '\u{2694}\u{FE0F}', color: Color(0xFFE8B86D)),
  _AvatarPreset(name: 'Dragon', emoji: '\u{1F409}', color: Color(0xFFE53935)),
  _AvatarPreset(name: 'Fox', emoji: '\u{1F98A}', color: Color(0xFFFF9800)),
  _AvatarPreset(name: 'Eagle', emoji: '\u{1F985}', color: Color(0xFF795548)),
  _AvatarPreset(name: 'Wolf', emoji: '\u{1F43A}', color: Color(0xFF9E9E9E)),
];

class _Badge {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final Color color;
  final bool Function(QuizState qp) unlocked;

  const _Badge({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
    required this.unlocked,
  });
}

final _badges = [
  _Badge(
    id: 'first_stamp',
    name: 'First Stamp',
    icon: Icons.emoji_events,
    description: 'Earn your first XP',
    color: Color(0xFFE8B86D),
    unlocked: (qp) => qp.stamps >= 1,
  ),
  _Badge(
    id: 'streak_3',
    name: 'On Fire',
    icon: Icons.local_fire_department,
    description: 'Reach a streak of 3',
    color: Color(0xFFFF6B6B),
    unlocked: (qp) => qp.bestStreak >= 3,
  ),
  _Badge(
    id: 'streak_5',
    name: 'Streak Master',
    icon: Icons.whatshot,
    description: 'Reach a streak of 5',
    color: Color(0xFFFF9800),
    unlocked: (qp) => qp.bestStreak >= 5,
  ),
  _Badge(
    id: 'double_digits',
    name: 'Double Digits',
    icon: Icons.whatshot,
    description: 'Reach a streak of 10',
    color: Color(0xFFE53935),
    unlocked: (qp) => qp.bestStreak >= 10,
  ),
  _Badge(
    id: 'century',
    name: 'Century',
    icon: Icons.monetization_on,
    description: 'Earn 100 total XP',
    color: Color(0xFFE8B86D),
    unlocked: (qp) => qp.stamps >= 100,
  ),
  _Badge(
    id: 'quiz_whiz',
    name: 'Quiz Whiz',
    icon: Icons.school,
    description: 'Answer 50 questions',
    color: Color(0xFF42A5F5),
    unlocked: (qp) => qp.totalAnswered >= 50,
  ),
  _Badge(
    id: 'scholar',
    name: 'Scholar',
    icon: Icons.menu_book,
    description: 'Earn 500 total XP',
    color: Color(0xFF7B2FBE),
    unlocked: (qp) => qp.stamps >= 500,
  ),
  _Badge(
    id: 'legend',
    name: 'Legend',
    icon: Icons.auto_awesome,
    description: 'Earn 1000 total XP',
    color: Color(0xFFFFD700),
    unlocked: (qp) => qp.stamps >= 1000,
  ),
  _Badge(
    id: 'sharpshooter',
    name: 'Sharpshooter',
    icon: Icons.track_changes,
    description: '80%+ accuracy over 20+ answers',
    color: Color(0xFF43A047),
    unlocked: (qp) => qp.totalAnswered >= 20 && qp.totalCorrect / qp.totalAnswered >= 0.8,
  ),
  _Badge(
    id: 'grinder',
    name: 'Grinder',
    icon: Icons.hourglass_bottom,
    description: 'Answer 100 questions',
    color: Color(0xFF795548),
    unlocked: (qp) => qp.totalAnswered >= 100,
  ),
];

String _titleForXp(int xp) {
  if (xp >= 10000) return 'Grand Sage';
  if (xp >= 5000) return 'Wisdom Keeper';
  if (xp >= 2500) return 'Knowledge Seeker';
  if (xp >= 1000) return 'Trivia Master';
  if (xp >= 500) return 'XP Hunter';
  if (xp >= 100) return 'Quiz Apprentice';
  return 'Stamp Collector';
}

int _levelForXp(int xp) => (sqrt(xp / 100).floor()) + 1;

int _xpForLevel(int level) => level * level * 100;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static final _nameFormKey = GlobalKey<FormState>();
  static final _passwordFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final quiz = context.watch<QuizBloc>().state;
    final canChangePassword = context.read<AuthBloc>().canChangePassword;

    final xp = quiz.stamps;
    final level = _levelForXp(xp);
    final xpForCurrent = _xpForLevel(level - 1);
    final xpForNext = _xpForLevel(level);
    final progress = (xp - xpForCurrent) / (xpForNext - xpForCurrent);
    final title = _titleForXp(xp);
    final avatarIndex = auth.avatarIndex.clamp(0, _avatarPresets.length - 1);
    final avatar = _avatarPresets[avatarIndex];
    final accuracy = quiz.totalAnswered > 0 ? quiz.totalCorrect / quiz.totalAnswered : 0.0;

    final unlockedBadges = _badges.where((b) => b.unlocked(quiz)).toList();
    final lockedBadges = _badges.where((b) => !b.unlocked(quiz)).toList();

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
            _buildProfileHeader(auth, avatar, title),
            SizedBox(height: 2.h),
            _buildLevelBar(level, xp, xpForNext, progress),
            SizedBox(height: 2.h),
            _buildStatsRow(xp, quiz, accuracy),
            SizedBox(height: 2.h),
            _buildStreakDisplay(quiz),
            SizedBox(height: 2.h),
            _buildBadgeSection(unlockedBadges, lockedBadges),
            SizedBox(height: 3.h),
            _buildSettingsSection(context, auth, avatar, canChangePassword: canChangePassword),
            SizedBox(height: 4.h),
            _buildSignOut(context),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthState auth, _AvatarPreset avatar, String title) {
    return Column(
      children: [
        Container(
          width: 22.w,
          height: 22.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avatar.color.withValues(alpha: 0.2),
            border: Border.all(color: avatar.color, width: 3),
            boxShadow: [BoxShadow(color: avatar.color.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 5)],
          ),
          child: Center(
            child: Text(avatar.emoji, style: TextStyle(fontSize: 11.w)),
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          auth.user?.name ?? 'Player',
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 0.3.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.3.h),
          decoration: BoxDecoration(
            color: const Color(0xFF7B2FBE).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF7B2FBE)),
          ),
          child: Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFFE8B86D), fontWeight: FontWeight.bold),
          ),
        ),
        if (auth.user?.email != null && auth.user!.email!.isNotEmpty) ...[
          SizedBox(height: 0.5.h),
          Text(auth.user!.email!, style: TextStyle(fontSize: 13.sp, color: Colors.white38)),
        ],
      ],
    );
  }

  Widget _buildLevelBar(int level, int xp, int xpForNext, double progress) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Level $level', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFFE8B86D))),
              Text('$xp / $xpForNext XP', style: TextStyle(fontSize: 13.sp, color: Colors.white54)),
            ],
          ),
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 1.8.h,
              backgroundColor: const Color(0xFF16213E),
              color: const Color(0xFF7B2FBE),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% to Level ${level + 1}',
            style: TextStyle(fontSize: 12.sp, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int xp, QuizState quiz, double accuracy) {
    return Row(
      children: [
        _statCard(Icons.monetization_on, '$xp', 'Total XP', const Color(0xFFE8B86D)),
        SizedBox(width: 2.w),
        _statCard(Icons.check_circle, '${quiz.totalCorrect}', 'Correct', const Color(0xFF43A047)),
        SizedBox(width: 2.w),
        _statCard(Icons.school, '${quiz.totalAnswered}', 'Answered', const Color(0xFF42A5F5)),
        SizedBox(width: 2.w),
        _statCard(Icons.track_changes, '${(accuracy * 100).toStringAsFixed(0)}%', 'Accuracy', const Color(0xFFFF6B6B)),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 5.w),
            SizedBox(height: 0.5.h),
            Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakDisplay(QuizState quiz) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.local_fire_department, color: const Color(0xFFFF6B6B), size: 8.w),
          ),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Streak', style: TextStyle(fontSize: 13.sp, color: Colors.white54)),
              Text(
                '${quiz.currentStreak}',
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Best Streak', style: TextStyle(fontSize: 13.sp, color: Colors.white54)),
              Row(
                children: [
                  Icon(Icons.whatshot, color: const Color(0xFFE8B86D), size: 5.w),
                  SizedBox(width: 1.w),
                  Text(
                    '${quiz.bestStreak}',
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: const Color(0xFFE8B86D)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeSection(List<_Badge> unlocked, List<_Badge> locked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Achievements', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: const Color(0xFFE8B86D))),
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF7B2FBE).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${unlocked.length}/${_badges.length}',
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFFE8B86D), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        if (unlocked.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Play quizzes to earn your first badge!',
              style: TextStyle(fontSize: 14.sp, color: Colors.white38),
              textAlign: TextAlign.center,
            ),
          )
        else
          Wrap(
            spacing: 2.w,
            runSpacing: 1.5.h,
            children: [
              ...unlocked.map((b) => _badgeChip(b, true)),
              ...locked.map((b) => _badgeChip(b, false)),
            ],
          ),
      ],
    );
  }

  Widget _badgeChip(_Badge badge, bool unlocked) {
    return Tooltip(
      message: '${badge.name}\n${badge.description}',
      child: Container(
        width: 20.w,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: unlocked ? badge.color.withValues(alpha: 0.15) : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unlocked ? badge.color : Colors.white12,
            width: unlocked ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              badge.icon,
              color: unlocked ? badge.color : Colors.white24,
              size: 7.w,
            ),
            SizedBox(height: 0.3.h),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 10.sp,
                color: unlocked ? Colors.white : Colors.white38,
                fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthState auth, _AvatarPreset avatar, {required bool canChangePassword}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avatar', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: const Color(0xFFE8B86D))),
        SizedBox(height: 1.h),
        _buildAvatarPicker(context),
        SizedBox(height: 3.h),
        _buildNameForm(context, auth),
        if (canChangePassword) ...[
          SizedBox(height: 3.h),
          _buildPasswordForm(context),
        ],
      ],
    );
  }

  Widget _buildAvatarPicker(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final selectedIndex = auth.avatarIndex.clamp(0, _avatarPresets.length - 1);

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: List.generate(_avatarPresets.length, (i) {
        final p = _avatarPresets[i];
        final selected = selectedIndex == i;
        return GestureDetector(
          onTap: () => context.read<AuthBloc>().add(AuthUpdateAvatarColor(colorIndex: i)),
          child: Container(
            width: 19.w,
            padding: EdgeInsets.symmetric(vertical: 0.8.h),
            decoration: BoxDecoration(
              color: selected ? p.color.withValues(alpha: 0.25) : const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? p.color : Colors.white12,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(p.emoji, style: TextStyle(fontSize: 7.w)),
                SizedBox(height: 0.2.h),
                Text(p.name, style: TextStyle(fontSize: 10.sp, color: selected ? Colors.white : Colors.white54)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNameForm(BuildContext context, AuthState auth) {
    String? nameValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display Name', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: const Color(0xFFE8B86D))),
        SizedBox(height: 1.h),
        Form(
          key: _nameFormKey,
          child: TextFormField(
            initialValue: auth.user?.name ?? '',
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Enter your name'),
            onSaved: (v) => nameValue = v,
          ),
        ),
        SizedBox(height: 1.5.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: _buttonStyle(),
            onPressed: () {
              _nameFormKey.currentState!.save();
              final name = (nameValue ?? '').trim();
              if (name.isEmpty) return;
              context.read<AuthBloc>().add(AuthUpdateDisplayName(name: name));
              _showSnack(context, 'Name updated!', false);
            },
            child: const Text('Save Name'),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm(BuildContext context) {
    String? currentPassword;
    String? newPassword;
    String? confirmPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Change Password', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: const Color(0xFFE8B86D))),
        SizedBox(height: 1.h),
        Form(
          key: _passwordFormKey,
          child: Column(
            children: [
              TextFormField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Current password'),
                onSaved: (v) => currentPassword = v,
              ),
              SizedBox(height: 1.h),
              TextFormField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('New password'),
                onSaved: (v) => newPassword = v,
              ),
              SizedBox(height: 1.h),
              TextFormField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Confirm new password'),
                onSaved: (v) => confirmPassword = v,
              ),
            ],
          ),
        ),
        SizedBox(height: 1.5.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: _buttonStyle(),
            onPressed: () {
              _passwordFormKey.currentState!.save();
              final current = (currentPassword ?? '').trim();
              final newPass = (newPassword ?? '').trim();
              final confirm = (confirmPassword ?? '').trim();
              if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                _showSnack(context, 'Fill in all fields', true); return;
              }
              if (newPass.length < 6) {
                _showSnack(context, 'Password must be at least 6 characters', true); return;
              }
              if (newPass != confirm) {
                _showSnack(context, 'Passwords do not match', true); return;
              }
              context.read<AuthBloc>().add(AuthUpdatePassword(currentPassword: current, newPassword: newPass));
              _passwordFormKey.currentState!.reset();
              _showSnack(context, 'Password updated!', false);
            },
            child: const Text('Update Password'),
          ),
        ),
      ],
    );
  }

  Widget _buildSignOut(BuildContext context) {
    return SizedBox(
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
          final navigator = Navigator.of(context);
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
            context.read<AuthBloc>().add(AuthSignOut());
            navigator.popUntil((route) => route.isFirst);
          }
        },
        label: const Text('Sign Out'),
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

  void _showSnack(BuildContext context, String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade800 : const Color(0xFF7B2FBE),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
