import 'dart:async';

import 'package:app/src/features/onboarding/application/onboarding_controller.dart';
import 'package:app/src/features/onboarding/presentation/widgets/onboarding_page_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NameInputPage extends ConsumerStatefulWidget {
  const NameInputPage({super.key});

  @override
  ConsumerState<NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends ConsumerState<NameInputPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(onboardingControllerProvider).answers.name;
    _controller = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      icon: Icons.badge_outlined,
      title: 'What should we call you?',
      subtitle:
          "We'll use this to personalise the app. You can change it later.",
      child: TextField(
        key: const Key('onboarding.name'),
        controller: _controller,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Your name',
          hintText: 'e.g. Alex',
        ),
        onChanged: (value) {
          unawaited(
            ref
                .read(onboardingControllerProvider.notifier)
                .setName(value.trim()),
          );
        },
      ),
    );
  }
}
