import 'package:app/src/features/onboarding/presentation/widgets/onboarding_page_layout.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageLayout(
      icon: Icons.waving_hand_outlined,
      title: 'Welcome',
      subtitle:
          "We're glad you're here. The next few screens will show you "
          'around and learn a little about what you want to get out of the '
          'app.',
    );
  }
}
