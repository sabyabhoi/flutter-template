import 'package:app/src/core/theme/tokens/app_radii.dart';
import 'package:app/src/core/theme/tokens/app_spacing.dart';
import 'package:app/src/features/onboarding/application/onboarding_controller.dart';
import 'package:app/src/features/onboarding/presentation/pages/auth_handoff_page.dart';
import 'package:app/src/features/onboarding/presentation/pages/goal_page.dart';
import 'package:app/src/features/onboarding/presentation/pages/how_it_works_page.dart';
import 'package:app/src/features/onboarding/presentation/pages/motivation_page.dart';
import 'package:app/src/features/onboarding/presentation/pages/name_input_page.dart';
import 'package:app/src/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// First-launch onboarding flow.
///
/// Six pages — two informational, three quiz, one auth-handoff — hosted
/// inside a [PageView] with a dot indicator and a Back/Next bar.
/// Reaching the final page calls `OnboardingController.complete()` so the
/// router stops gating the user on `/onboarding` from then on.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const List<Widget> _pages = <Widget>[
    WelcomePage(),
    HowItWorksPage(),
    NameInputPage(),
    MotivationPage(),
    GoalPage(),
    AuthHandoffPage(),
  ];

  static const Duration _animationDuration = Duration(milliseconds: 280);
  static const Curve _animationCurve = Curves.easeOutCubic;

  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _pages.length - 1;

  void _onPageChanged(int index) {
    setState(() => _index = index);
    if (index == _pages.length - 1) {
      // Mark complete so closing the app from the auth page doesn't replay
      // the tour. Idempotent.
      // ignore: discarded_futures
      ref.read(onboardingControllerProvider.notifier).complete();
    }
  }

  Future<void> _next() async {
    if (_isLast) return;
    await _controller.nextPage(
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  Future<void> _back() async {
    if (_index == 0) return;
    await _controller.previousPage(
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.sm,
              ),
              child: _PageIndicator(count: _pages.length, index: _index),
            ),
            Expanded(
              child: PageView(
                key: const Key('onboarding.pageView'),
                controller: _controller,
                onPageChanged: _onPageChanged,
                children: _pages,
              ),
            ),
            if (!_isLast)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.sm,
                    AppSpacing.xxl,
                    AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        key: const Key('onboarding.back'),
                        onPressed: _index == 0 ? null : _back,
                        child: const Text('Back'),
                      ),
                      const Spacer(),
                      FilledButton(
                        key: const Key('onboarding.next'),
                        onPressed: _next,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: AppSpacing.sm,
              width: i == index ? AppSpacing.xxl : AppSpacing.sm,
              decoration: BoxDecoration(
                color: i == index
                    ? colors.primary
                    : colors.surfaceContainerHighest,
                borderRadius: AppRadii.fullR,
              ),
            ),
          ),
      ],
    );
  }
}
