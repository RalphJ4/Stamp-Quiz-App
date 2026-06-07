import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:confetti/confetti.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// Purely visual repeating pulse — AnimationController requires TickerProvider (StatefulWidget)
class _PulseEffect extends StatefulWidget {
  final Widget Function(BuildContext context, double value) builder;
  const _PulseEffect({required this.builder});
  @override
  State<_PulseEffect> createState() => _PulseEffectState();
}

class _PulseEffectState extends State<_PulseEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
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
      builder: (context, _) => widget.builder(context, _controller.value),
    );
  }
}

class _ShakeEffect extends StatelessWidget {
  final int triggerKey;
  final Widget child;
  const _ShakeEffect({required this.triggerKey, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(triggerKey),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(_shakeOffset(value), 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Maps 0→1 to the shake sequence 0→-8→8→-5→5→0
  static double _shakeOffset(double t) {
    if (t < 1 / 8) return _lerp(0, -8, t * 8);
    if (t < 3 / 8) return _lerp(-8, 8, (t - 1 / 8) * 4);
    if (t < 5 / 8) return _lerp(8, -5, (t - 3 / 8) * 4);
    if (t < 7 / 8) return _lerp(-5, 5, (t - 5 / 8) * 4);
    return _lerp(5, 0, (t - 7 / 8) * 8);
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

final _pageController = PageController();
final _confettiWidgetController = ConfettiController(duration: const Duration(seconds: 3));

class GamifiedOnboardingScreen extends StatelessWidget {
  final VoidCallback onComplete;
  const GamifiedOnboardingScreen({super.key, required this.onComplete});

  void _goNext(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();
    final next = bloc.state.currentStep + 1;
    if (next >= bloc.state.stepCount) return;
    bloc.add(OnboardingNextStep());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _finish(BuildContext context) {
    context.read<OnboardingBloc>().add(OnboardingComplete());
    onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D1A),
          body: SafeArea(
            child: Column(
              children: [
                if (state.currentStep < 4)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Row(
                      children: [
                        Text(
                          'Step ${state.currentStep + 1} of ${state.stepCount}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white54,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _finish(context),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFFE8B86D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _WelcomeStep(onNext: () => _goNext(context)),
                      _NameStep(onNext: () => _goNext(context)),
                      _AvatarStep(onNext: () => _goNext(context)),
                      _TutorialStep(onNext: () => _goNext(context)),
                      _CongratulationsStep(onFinish: () => _finish(context)),
                    ],
                  ),
                ),
                if (state.currentStep < 4)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        state.stepCount - 1,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          width: state.currentStep == i ? 6.w : 2.5.w,
                          height: 1.h,
                          decoration: BoxDecoration(
                            color: state.currentStep >= i
                                ? const Color(0xFFE8B86D)
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _PulseEffect(
      builder: (context, pulse) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Transform.scale(
                scale: 0.9 + (pulse * 0.1),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE8B86D).withValues(alpha: 0.3 * pulse),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/stamp.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Stamp Quiz',
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8B86D),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Collect stamps, test your knowledge!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: Colors.white54),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2FBE),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 22),
                  onPressed: onNext,
                  label: Text("Let's Start!", style: TextStyle(fontSize: 18.sp)),
                ),
              ),
              SizedBox(height: 3.h),
            ],
          ),
        );
      },
    );
  }
}

class _NameStep extends StatelessWidget {
  final VoidCallback onNext;

  const _NameStep({required this.onNext});

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String? name;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(Icons.person_outline, color: const Color(0xFFE8B86D), size: 12.h),
          SizedBox(height: 3.h),
          Text(
            'What should we call you?',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 3.h),
          Form(
            key: _formKey,
            child: TextFormField(
              initialValue: context.watch<OnboardingBloc>().state.playerName,
              maxLength: 20,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(fontSize: 18.sp, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF16213E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF7B2FBE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8B86D), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                counterStyle: const TextStyle(color: Colors.white38),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a name' : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onSaved: (v) => name = v,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B2FBE),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              icon: const Icon(Icons.arrow_forward, size: 22),
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                _formKey.currentState!.save();
                final trimmed = (name ?? '').trim();
                context.read<OnboardingBloc>().add(OnboardingSetPlayerName(name: trimmed));
                onNext();
              },
              label: Text('Next', style: TextStyle(fontSize: 18.sp)),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _AvatarStep extends StatelessWidget {
  final VoidCallback onNext;
  const _AvatarStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingBloc>().state;
    final colors = OnboardingState.presetColors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 20.h,
            height: 20.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: state.avatarColor,
              border: Border.all(color: const Color(0xFFE8B86D), width: 3),
              boxShadow: [
                BoxShadow(
                  color: state.avatarColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                (state.playerName.isNotEmpty
                        ? state.playerName[0]
                        : '?')
                    .toUpperCase(),
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Pick your avatar colour',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 3.h),
          Wrap(
            spacing: 3.w,
            runSpacing: 2.h,
            alignment: WrapAlignment.center,
            children: colors.map((color) {
              final selected = state.avatarColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => context.read<OnboardingBloc>().add(OnboardingSetAvatarColor(color: color)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 14.w : 12.w,
                  height: selected ? 14.w : 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: selected ? const Color(0xFFE8B86D) : Colors.transparent,
                      width: selected ? 3 : 0,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 3)]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 28)
                      : null,
                ),
              );
            }).toList(),
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
                elevation: 4,
              ),
              icon: const Icon(Icons.arrow_forward, size: 22),
              onPressed: onNext,
              label: Text('Next', style: TextStyle(fontSize: 18.sp)),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _TutorialStep extends StatelessWidget {
  final VoidCallback onNext;

  const _TutorialStep({required this.onNext});

  static const _options = ['Inverted Jenny', 'Flying Dolphin', 'Space Penguin', 'Rainbow Rocket'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingBloc>().state;
    final selectedOption = state.tutorialSelectedIndex;
    final correct = state.tutorialCorrect;
    final answered = state.tutorialAnswered;
    final wrongAttempts = state.tutorialWrongAttempts;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(Icons.school, color: const Color(0xFFE8B86D), size: 8.h),
          SizedBox(height: 2.h),
          Text(
            'Try a practice question!',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Tap the correct answer to see how it works.',
            style: TextStyle(fontSize: 15.sp, color: Colors.white54),
          ),
          SizedBox(height: 2.h),
          Card(
            color: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Text(
                'Which of these is a real postage stamp?',
                style: TextStyle(fontSize: 17.sp, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          _ShakeEffect(
            triggerKey: wrongAttempts,
            child: Column(
              children: List.generate(_options.length, (i) {
                final isSelected = selectedOption == i;
                final isCorrect = i == 0;
                Color? tileColor;
                if (selectedOption != -1) {
                  if (isCorrect) {
                    tileColor = Colors.green.withValues(alpha: 0.2);
                  } else if (isSelected) {
                    tileColor = Colors.red.withValues(alpha: 0.2);
                  }
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: GestureDetector(
                    onTap: correct
                        ? null
                        : () {
                            context.read<OnboardingBloc>().add(OnboardingTutorialSelect(index: i));
                            if (i == 0) _confettiWidgetController.play();
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: tileColor ?? const Color(0xFF16213E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: tileColor ??
                              (isSelected ? const Color(0xFFE8B86D) : Colors.white24),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _options[i],
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: selectedOption != -1
                                    ? (isCorrect
                                        ? Colors.green[300]
                                        : isSelected
                                            ? Colors.red[300]
                                            : Colors.white70)
                                    : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (correct && isCorrect)
                            const Icon(Icons.check_circle, color: Colors.green, size: 24),
                          if (selectedOption != -1 && isSelected && !isCorrect)
                            const Icon(Icons.cancel, color: Colors.red, size: 24),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (answered) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE8B86D).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8B86D)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFFE8B86D), size: 20),
                  SizedBox(width: 2.w),
                  Text(
                    '+1 XP  \u2022  Streak +1',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFFE8B86D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2FBE),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                icon: const Icon(Icons.arrow_forward, size: 22),
                onPressed: onNext,
                label: Text('Nice! Continue', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
          ],
          if (selectedOption != -1 && !correct)
            Padding(
              padding: EdgeInsets.only(top: 0.5.h),
              child: Text(
                'Not quite \u2014 try again!',
                style: TextStyle(fontSize: 15.sp, color: Colors.orange),
              ),
            ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _CongratulationsStep extends StatelessWidget {
  final VoidCallback onFinish;

  const _CongratulationsStep({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    _confettiWidgetController.play();
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 35.w,
                  height: 35.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE8B86D).withValues(alpha: 0.5),
                        blurRadius: 50,
                        spreadRadius: 15,
                      ),
                    ],
                    border: Border.all(color: const Color(0xFF7B2FBE), width: 3),
                    color: Colors.white,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/stamp.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'You earned your first stamp!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8B86D),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Answer questions, collect stamps,\nand build your streak!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: Colors.white54),
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statItem(Icons.monetization_on, '1 XP', const Color(0xFFE8B86D)),
                    Container(width: 1, height: 4.h, color: Colors.white12),
                    _statItem(Icons.local_fire_department, 'Streak 1', Colors.orange),
                    Container(width: 1, height: 4.h, color: Colors.white12),
                    _statItem(Icons.emoji_events, '1 Stamp', const Color(0xFFE8B86D)),
                  ],
                ),
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
                    elevation: 6,
                  ),
                  icon: const Icon(Icons.rocket_launch, size: 24),
                  onPressed: onFinish,
                  label: Text('Start Your Adventure', style: TextStyle(fontSize: 18.sp)),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiWidgetController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.04,
            numberOfParticles: 40,
            maxBlastForce: 25,
            minBlastForce: 10,
            gravity: 0.15,
          ),
        ),
      ],
    );
  }

  Widget _statItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 5.w),
        SizedBox(height: 0.3.h),
        Text(label, style: TextStyle(fontSize: 14.sp, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
