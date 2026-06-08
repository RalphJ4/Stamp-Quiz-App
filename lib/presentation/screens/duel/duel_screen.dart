import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/domain/entities/duel.dart';
import 'package:quiz_app/presentation/screens/duel/bloc/duel_bloc.dart';
import 'package:quiz_app/presentation/screens/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:confetti/confetti.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';

final _log = Logger();

class _DuelJoinForm extends StatelessWidget {
  const _DuelJoinForm();

  @override
  Widget build(BuildContext context) {
    String code = '';
    return Form(
      key: GlobalKey<FormState>(),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              onChanged: (v) => code = v,
              decoration: InputDecoration(
                hintText: 'Enter duel code',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 3.w, vertical: 1.5.h),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textCapitalization: TextCapitalization.none,
            ),
          ),
          SizedBox(width: 2.w),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.background,
              padding: EdgeInsets.symmetric(
                  horizontal: 4.w, vertical: 1.8.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final trimmed = code.trim();
              if (trimmed.isEmpty) return;
              _log.i('Joining duel: $trimmed');
              context.read<DuelBloc>().add(DuelJoin(duelId: trimmed));
            },
            child: Text('Join', style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }
}

// Purely visual animation — AnimationController requires TickerProvider (StatefulWidget)
class _WaitingDotsAnimation extends StatefulWidget {
  const _WaitingDotsAnimation();
  @override
  State<_WaitingDotsAnimation> createState() => _WaitingDotsAnimationState();
}
class _WaitingDotsAnimationState extends State<_WaitingDotsAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = (_controller.value + delay) % 1.0;
            final opacity = sin(t * pi);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w),
              child: Container(
                width: 2.5.w,
                height: 2.5.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary
                      .withValues(alpha: opacity),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// Purely visual — ConfettiController requires TickerProvider (StatefulWidget)
class _WinConfetti extends StatefulWidget {
  final bool play;
  const _WinConfetti({required this.play});
  @override
  State<_WinConfetti> createState() => _WinConfettiState();
}
class _WinConfettiState extends State<_WinConfetti> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));
    if (widget.play) _controller.play();
  }

  @override
  void didUpdateWidget(_WinConfetti old) {
    super.didUpdateWidget(old);
    if (widget.play && !old.play) _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: _controller,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      emissionFrequency: 0.05,
      numberOfParticles: 50,
      maxBlastForce: 30,
      minBlastForce: 10,
      gravity: 0.15,
    );
  }
}

class DuelScreen extends StatelessWidget {
  const DuelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DuelBloc, DuelBlocState>(
      builder: (context, state) {
        if (state.duel == null && !state.loading) {
          return _buildLobbyEntry(context, state);
        }
        if (state.loading) {
          return _buildLoading();
        }
        if (state.duel == null) {
          return _buildLobbyEntry(context, state);
        }

        switch (state.duel!.status) {
          case DuelStatus.waiting:
            return _buildWaitingLobby(context, state);
          case DuelStatus.active:
            return _buildActiveDuel(context, state);
          case DuelStatus.complete:
            return _buildWinner(context, state);
        }
      },
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
    );
  }

  Widget _buildLobbyEntry(BuildContext context, DuelBlocState state) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Duel Mode',
            style: TextStyle(color: AppColors.secondary)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        toolbarHeight: 7.h,
      ),
      body: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports,
                color: AppColors.secondary, size: 15.h),
            SizedBox(height: 3.h),
            Text(
              'Challenge a friend in real-time!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add),
                onPressed: () {
                  _log.i('Creating duel...');
                  context.read<DuelBloc>().add(DuelCreate());
                },
                label: Text('Create Duel', style: TextStyle(fontSize: 17.sp)),
              ),
            ),
            SizedBox(height: 2.h),
            const _DuelJoinForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingLobby(BuildContext context, DuelBlocState state) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Waiting for Opponent',
            style: TextStyle(color: AppColors.secondary)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        toolbarHeight: 7.h,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            context.read<DuelBloc>().add(DuelReset());
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_tethering,
                  color: AppColors.secondary, size: 12.h),
              SizedBox(height: 2.h),
              Text(
                'Share this code with your opponent:',
                style: TextStyle(fontSize: 16.sp, color: Colors.white70),
              ),
              SizedBox(height: 2.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: SelectableText(
                  state.currentDuelId ?? '',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              const _WaitingDotsAnimation(),
              SizedBox(height: 2.h),
              Text(
                'Waiting for player to join...',
                style: TextStyle(fontSize: 15.sp, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveDuel(BuildContext context, DuelBlocState state) {
    final duel = state.duel!;
    final uid = context.read<AuthBloc>().state.user?.id ?? '';
    final isMeHost = duel.hostUid == uid;
    final myProg = isMeHost ? duel.hostProgress : duel.guestProgress;

    if (myProg >= duel.questions.length) {
      return _buildWaitingOthers();
    }

    final question = duel.questions[myProg];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Duel',
            style: TextStyle(color: AppColors.secondary)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        toolbarHeight: 7.h,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              context.read<DuelBloc>().add(DuelReset());
              Navigator.of(context).pop();
            },
          ),
          actions: [
          Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: state.remainingSeconds <= 10
                      ? Colors.red
                      : AppColors.secondary,
                  size: 5.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${state.remainingSeconds}s',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: state.remainingSeconds <= 10
                        ? Colors.red
                        : AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          children: [
            _buildHud(context, state),
            SizedBox(height: 1.5.h),
            LinearProgressIndicator(
              value: (myProg + 1) / duel.questions.length,
              backgroundColor: AppColors.surfaceDark,
              color: AppColors.secondary,
              minHeight: 1.2.h,
            ),
            SizedBox(height: 1.h),
            Text(
              'Your Question ${myProg + 1} of ${duel.questions.length}',
              style: TextStyle(fontSize: 14.sp, color: Colors.white54),
            ),
            SizedBox(height: 1.5.h),
            Card(
              color: AppColors.surface,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  question.question,
                  style: TextStyle(
                      fontSize: 17.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(height: 1.5.h),
            ...List.generate(question.options.length, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceDark,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white24),
                      ),
                    ),
                    onPressed: () {
                      final isCorrect = question.correctIndex == i;
                      context.read<DuelBloc>().add(DuelSubmitAnswer(isCorrect: isCorrect));
                    },
                    child: Text(question.options[i],
                        style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHud(BuildContext context, DuelBlocState state) {
    final duel = state.duel!;

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _playerCard(
            label: 'You',
            score: context.read<DuelBloc>().myScore,
            progress: context.read<DuelBloc>().myProgress,
            total: duel.questions.length,
            color: AppColors.primary,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child:             Icon(Icons.sports_kabaddi,
                color: AppColors.secondary, size: 5.w),
          ),
          _playerCard(
            label: 'Opponent',
            score: context.read<DuelBloc>().opponentScore,
            progress: context.read<DuelBloc>().opponentProgress,
            total: duel.questions.length,
            color: const Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }

  Widget _playerCard({
    required String label,
    required int score,
    required int progress,
    required int total,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13.sp,
                    color: color,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 0.5.h),
            Text('$score',
                style: TextStyle(
                    fontSize: 22.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            Text('$progress/$total',
                style: TextStyle(fontSize: 12.sp, color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingOthers() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Duel',
            style: TextStyle(color: AppColors.secondary)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        toolbarHeight: 7.h,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_top,
                color: AppColors.secondary, size: 10.h),
            SizedBox(height: 2.h),
            Text(
              'Waiting for opponent to finish...',
              style: TextStyle(fontSize: 17.sp, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinner(BuildContext context, DuelBlocState state) {
    final duel = state.duel!;
    final authUid = context.read<AuthBloc>().state.user?.id ?? '';
    final isWinner = duel.winnerUid == authUid;
    final isTie = duel.winnerUid == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isWinner
                        ? Icons.emoji_events
                        : isTie
                            ? Icons.handshake
                            : Icons.sentiment_dissatisfied,
                    size: 18.h,
                    color: isWinner
                        ? AppColors.secondary
                        : Colors.white54,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isWinner
                        ? 'You Win!'
                        : isTie
                            ? "It's a Tie!"
                            : 'You Lost',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: isWinner
                          ? AppColors.secondary
                          : Colors.white70,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '${duel.hostScore} - ${duel.guestScore}',
                    style: TextStyle(
                        fontSize: 22.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2.h),
                  if (isWinner)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monetization_on,
                              color: AppColors.secondary, size: 5.w),
                          SizedBox(width: 2.w),
                          Text('+50 XP',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  SizedBox(height: 1.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.monetization_on,
                            color: AppColors.secondary, size: 5.w),
                        SizedBox(width: 2.w),
                        Text('+20 XP Participation',
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 1.8.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      context.read<DuelBloc>().awardXp();
                      context.read<LeaderboardBloc>().forceSync();
                      context.read<DuelBloc>().add(DuelReset());
                      Navigator.of(context).pop();
                    },
                    label:
                        Text('Back to Home', style: TextStyle(fontSize: 16.sp)),
                  ),
                ],
              ),
            ),
          ),
          _WinConfetti(play: isWinner || isTie),
        ],
      ),
    );
  }
}
