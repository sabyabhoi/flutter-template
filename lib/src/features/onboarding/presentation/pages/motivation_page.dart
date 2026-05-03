import 'dart:async';

import 'package:app/src/core/theme/tokens/app_spacing.dart';
import 'package:app/src/features/onboarding/application/onboarding_controller.dart';
import 'package:app/src/features/onboarding/presentation/widgets/onboarding_page_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _options = <String>[
  'Stay organised',
  'Save time',
  'Learn something new',
  'Connect with others',
  'Just exploring',
];

class MotivationPage extends ConsumerWidget {
  const MotivationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref
        .watch(onboardingControllerProvider)
        .answers
        .motivations
        .toSet();

    return OnboardingPageLayout(
      icon: Icons.flag_outlined,
      title: 'What brings you here?',
      subtitle: 'Pick any that apply — this helps us tailor your experience.',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final option in _options)
            FilterChip(
              key: Key('onboarding.motivation.$option'),
              label: Text(option),
              selected: selected.contains(option),
              onSelected: (value) {
                final next = {...selected};
                if (value) {
                  next.add(option);
                } else {
                  next.remove(option);
                }
                unawaited(
                  ref
                      .read(onboardingControllerProvider.notifier)
                      .setMotivations(next.toList()),
                );
              },
            ),
        ],
      ),
    );
  }
}
