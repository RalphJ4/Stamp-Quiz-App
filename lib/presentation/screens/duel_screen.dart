import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/domain/entities/duel.dart';
import 'package:quiz_app/presentation/provider/duel_provider.dart';
import 'package:quiz_app/presentation/provider/quiz_provider.dart';
import 'package:quiz_app/services/auth_mode_manager.dart';
import 'package:confetti/confetti.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final _log = Logger();

class DuelScreen extends StatefulWidget {
  const DuelScreen({super.key});

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> with TickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _confettiController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DuelProvider>(
      builder: (context, provider, _) {
        final state = provider.state;

        if (state == null && !provider.loading) {
          return _buildLobbyEntry(provider);
        }
        if (provider.loading) {
          return _buildLoading();
        }
        if (state == null) {
          return _buildLobbyEntry(provider);
        }

        switch (state.status) {
          case DuelStatus.waiting:
            return _buildWaitingLobby(provider);
          case DuelStatus.active:
            return _buildActiveDuel(provider);
          case DuelStatus.complete:
            return _buildWinner(provider);
        }
      },
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: const Center(child: CircularProgressIndicator(color: Color(0xFFE8B86D))),
    );
  }

  Widget _buildLobbyEntry(DuelProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Duel Mode',
            style: TextStyle(color: Color(0xFFE8B86D))),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A2E),
        toolbarHeight: 7.h,
      ),
      body: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports,
                color: const Color(0xFFE8B86D), size: 15.h),
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
                  backgroundColor: const Color(0xFF7B2FBE),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add),
                onPressed: () async {
                  _log.i('Creating duel...');
                  final err = await provider.createDuel();
                  if (err != null && context.mounted) {
                    _showError(err);
                  }
                },
                label: Text('Create Duel', style: TextStyle(fontSize: 17.sp)),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      hintText: 'Enter duel code',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF16213E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF7B2FBE)),
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
                    backgroundColor: const Color(0xFFE8B86D),
                    foregroundColor: const Color(0xFF0D0D1A),
                    padding: EdgeInsets.symmetric(
                        horizontal: 4.w, vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final code = _codeController.text.trim();
                    if (code.isEmpty) return;
                    _log.i('Joining duel: $code');
                    final err = await provider.joinDuel(code);
                    if (err != null && context.mounted) {
                      _showError(err);
                    }
                  },
                  child: Text('Join', style: TextStyle(fontSize: 16.sp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingLobby(DuelProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Waiting for Opponent',
            style: TextStyle(color: Color(0xFFE8B86D))),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A2E),
        toolbarHeight: 7.h,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            provider.reset();
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
                  color: const Color(0xFFE8B86D), size: 12.h),
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
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7B2FBE)),
                ),
                child: SelectableText(
                  provider.currentDuelId ?? '',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE8B86D),
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              AnimatedBuilder(
                animation: _dotController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final delay = i * 0.2;
                      final t = (_dotController.value + delay) % 1.0;
                      final opacity = sin(t * pi);
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                        child: Container(
                          width: 2.5.w,
                          height: 2.5.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8B86D)
                                .withValues(alpha: opacity),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
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

  Widget _buildActiveDuel(DuelProvider provider) {
    final state = provider.state!;
    final uid = context.read<AuthModeManager>().user?.id ?? '';
    final isMeHost = state.hostUid == uid;
    final myProg = isMeHost ? state.hostProgress : state.guestProgress;

    if (myProg >= state.questions.length) {
      return _buildWaitingOthers(provider);
    }

    final question = state.questions[myProg];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Duel',
            style: TextStyle(color: Color(0xFFE8B86D))),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A2E),
        toolbarHeight: 7.h,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            provider.reset();
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
                  color: provider.remainingSeconds <= 10
                      ? Colors.red
                      : const Color(0xFFE8B86D),
                  size: 5.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${provider.remainingSeconds}s',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: provider.remainingSeconds <= 10
                        ? Colors.red
                        : const Color(0xFFE8B86D),
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
            _buildHud(provider),
            SizedBox(height: 1.5.h),
            LinearProgressIndicator(
              value: (myProg + 1) / state.questions.length,
              backgroundColor: const Color(0xFF16213E),
              color: const Color(0xFFE8B86D),
              minHeight: 1.2.h,
            ),
            SizedBox(height: 1.h),
            Text(
              'Your Question ${myProg + 1} of ${state.questions.length}',
              style: TextStyle(fontSize: 14.sp, color: Colors.white54),
            ),
            SizedBox(height: 1.5.h),
            Card(
              color: const Color(0xFF1A1A2E),
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
                      backgroundColor: const Color(0xFF16213E),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white24),
                      ),
                    ),
                    onPressed: () {
                      final isCorrect = question.correctIndex == i;
                      provider.submitAnswer(isCorrect);
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

  Widget _buildHud(DuelProvider provider) {
    final state = provider.state!;

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _playerCard(
            label: 'You',
            score: provider.myScore,
            progress: provider.myProgress,
            total: state.questions.length,
            color: const Color(0xFF7B2FBE),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child:             Icon(Icons.sports_kabaddi,
                color: const Color(0xFFE8B86D), size: 5.w),
          ),
          _playerCard(
            label: 'Opponent',
            score: provider.opponentScore,
            progress: provider.opponentProgress,
            total: state.questions.length,
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

  Widget _buildWaitingOthers(DuelProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Duel',
            style: TextStyle(color: Color(0xFFE8B86D))),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A2E),
        toolbarHeight: 7.h,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_top,
                color: const Color(0xFFE8B86D), size: 10.h),
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

  Widget _buildWinner(DuelProvider provider) {
    final state = provider.state!;
    final authUid = context.read<AuthModeManager>().user?.id ?? '';
    final isWinner = state.winnerUid == authUid;
    final isTie = state.winnerUid == null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isWinner || isTie) _confettiController.play();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
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
                        ? const Color(0xFFE8B86D)
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
                          ? const Color(0xFFE8B86D)
                          : Colors.white70,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '${state.hostScore} - ${state.guestScore}',
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
                        color: const Color(0xFFE8B86D).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8B86D)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monetization_on,
                              color: const Color(0xFFE8B86D), size: 5.w),
                          SizedBox(width: 2.w),
                          Text('+50 XP',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  color: const Color(0xFFE8B86D),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  SizedBox(height: 1.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B2FBE).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF7B2FBE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.monetization_on,
                            color: const Color(0xFFE8B86D), size: 5.w),
                        SizedBox(width: 2.w),
                        Text('+20 XP Participation',
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xFFE8B86D),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2FBE),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 1.8.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      _awardXp(provider);
                      provider.reset();
                      Navigator.of(context).pop();
                    },
                    label:
                        Text('Back to Home', style: TextStyle(fontSize: 16.sp)),
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            maxBlastForce: 30,
            minBlastForce: 10,
            gravity: 0.15,
          ),
        ],
      ),
    );
  }

  void _awardXp(DuelProvider provider) {
    final state = provider.state;
    if (state == null) return;

    final authUid = context.read<AuthModeManager>().user?.id ?? '';
    final isWinner = state.winnerUid == authUid;

    final quizProvider = context.read<QuizProvider>();
    quizProvider.awardStamps(isWinner ? 50 : 20);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
