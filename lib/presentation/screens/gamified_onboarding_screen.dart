import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/presentation/provider/onboarding_provider.dart';
import 'package:confetti/confetti.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GamifiedOnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const GamifiedOnboardingScreen({super.key, required this.onComplete});

  @override
  State<GamifiedOnboardingScreen> createState() => _GamifiedOnboardingScreenState();
}

class _GamifiedOnboardingScreenState extends State<GamifiedOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _pulseController;
  late AnimationController _confettiController;
  final ConfettiController _confettiWidgetController =
      ConfettiController(duration: const Duration(seconds: 3));

  int _tutorialSelected = -1;
  bool _tutorialAnswered = false;
  bool _tutorialCorrect = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    _confettiWidgetController.dispose();
    super.dispose();
  }

  void _goNext() {
    final provider = context.read<OnboardingProvider>();
    final next = provider.currentStep + 1;
    if (next >= provider.stepCount) return;
    provider.nextStep();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _finish() async {
    final provider = context.read<OnboardingProvider>();
    await provider.completeOnboarding();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D1A),
          body: SafeArea(
            child: Column(
              children: [
                if (provider.currentStep < 4)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Row(
                      children: [
                        Text(
                          'Step ${provider.currentStep + 1} of ${provider.stepCount}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white54,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _finish,
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
                      _WelcomeStep(pulseController: _pulseController, onNext: _goNext),
                      _NameStep(onNext: _goNext),
                      _AvatarStep(onNext: _goNext),
                      _TutorialStep(
                        selectedOption: _tutorialSelected,
                        answered: _tutorialAnswered,
                        correct: _tutorialCorrect,
                        onSelect: (i) {
                          setState(() {
                            _tutorialSelected = i;
                            _tutorialAnswered = true;
                            _tutorialCorrect = i == 0;
                          });
                          if (i == 0) _confettiWidgetController.play();
                        },
                        onNext: _goNext,
                      ),
                      _CongratulationsStep(
                        confettiController: _confettiWidgetController,
                        onFinish: _finish,
                      ),
                    ],
                  ),
                ),
                if (provider.currentStep < 4)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        provider.stepCount - 1,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          width: provider.currentStep == i ? 6.w : 2.5.w,
                          height: 1.h,
                          decoration: BoxDecoration(
                            color: provider.currentStep >= i
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
  final AnimationController pulseController;
  final VoidCallback onNext;

  const _WelcomeStep({required this.pulseController, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) => Transform.scale(
              scale: 0.9 + (pulseController.value * 0.1),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8B86D).withValues(alpha: 0.3 * pulseController.value),
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
  }
}

class _NameStep extends StatefulWidget {
  final VoidCallback onNext;
  const _NameStep({required this.onNext});

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          TextField(
            controller: _controller,
            maxLength: 20,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(fontSize: 18.sp, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: const TextStyle(color: Colors.white38),
              errorText: _error,
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
            onChanged: (_) => setState(() => _error = null),
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
                final name = _controller.text.trim();
                if (name.isEmpty) {
                  setState(() => _error = 'Please enter a name');
                  return;
                }
                context.read<OnboardingProvider>().setPlayerName(name);
                widget.onNext();
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
    final provider = context.watch<OnboardingProvider>();
    final colors = OnboardingProvider.presetColors;

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
              color: provider.avatarColor,
              border: Border.all(color: const Color(0xFFE8B86D), width: 3),
              boxShadow: [
                BoxShadow(
                  color: provider.avatarColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                (provider.playerName.isNotEmpty
                        ? provider.playerName[0]
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
              final selected = provider.avatarColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => provider.setAvatarColor(color),
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

class _TutorialStep extends StatefulWidget {
  final int selectedOption;
  final bool answered;
  final bool correct;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  const _TutorialStep({
    required this.selectedOption,
    required this.answered,
    required this.correct,
    required this.onSelect,
    required this.onNext,
  });

  @override
  State<_TutorialStep> createState() => _TutorialStepState();
}

class _TutorialStepState extends State<_TutorialStep> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  static const _options = ['Inverted Jenny', 'Flying Dolphin', 'Space Penguin', 'Rainbow Rocket'];

  @override
  Widget build(BuildContext context) {
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
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final offset = widget.answered && !widget.correct ? _shakeAnimation.value : 0.0;
              return Transform.translate(offset: Offset(offset, 0), child: child);
            },
            child: Column(
              children: List.generate(_options.length, (i) {
                final isSelected = widget.selectedOption == i;
                final isCorrect = i == 0;
                Color? tileColor;
                if (widget.answered) {
                  if (isCorrect) {
                    tileColor = Colors.green.withValues(alpha: 0.2);
                  } else if (isSelected) {
                    tileColor = Colors.red.withValues(alpha: 0.2);
                  }
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: GestureDetector(
                    onTap: widget.answered
                        ? null
                        : () {
                            widget.onSelect(i);
                            if (i != 0) _shakeController.forward(from: 0);
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
                                color: widget.answered
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
                          if (widget.answered && isCorrect)
                            const Icon(Icons.check_circle, color: Colors.green, size: 24),
                          if (widget.answered && isSelected && !isCorrect)
                            const Icon(Icons.cancel, color: Colors.red, size: 24),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (widget.answered && widget.correct) ...[
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
                    '+1 XP  •  Streak +1',
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
                onPressed: widget.onNext,
                label: Text('Nice! Continue', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
          ],
          if (widget.answered && !widget.correct)
            Padding(
              padding: EdgeInsets.only(top: 0.5.h),
              child: Text(
                'Not quite — try again!',
                style: TextStyle(fontSize: 15.sp, color: Colors.orange),
              ),
            ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _CongratulationsStep extends StatefulWidget {
  final ConfettiController confettiController;
  final VoidCallback onFinish;

  const _CongratulationsStep({
    required this.confettiController,
    required this.onFinish,
  });

  @override
  State<_CongratulationsStep> createState() => _CongratulationsStepState();
}

class _CongratulationsStepState extends State<_CongratulationsStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _scaleAnimation = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);
    _scaleController.forward();
    widget.confettiController.play();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              ScaleTransition(
                scale: _scaleAnimation,
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
                  onPressed: widget.onFinish,
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
            confettiController: widget.confettiController,
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
