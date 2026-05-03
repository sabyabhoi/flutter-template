import 'package:app/src/core/theme/tokens/app_radii.dart';
import 'package:app/src/core/theme/tokens/app_spacing.dart';
import 'package:app/src/features/onboarding/application/onboarding_controller.dart';
import 'package:app/src/features/onboarding/presentation/widgets/onboarding_page_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _goals = <({String id, String title, String description})>[
  (
    id: 'starter',
    title: 'Just getting started',
    description: 'Show me the basics, one step at a time.',
  ),
  (
    id: 'regular',
    title: 'Make it a daily habit',
    description: 'Help me come back consistently.',
  ),
  (
    id: 'power',
    title: 'Go deep',
    description: 'Surface advanced features once I find my feet.',
  ),
];

class GoalPage extends ConsumerWidget {
  const GoalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingControllerProvider).answers.goal;

    return OnboardingPageLayout(
      icon: Icons.flag_circle_outlined,
      title: "What's your goal?",
      subtitle: 'Pick the one that fits best — pick a different one any time.',
      child: Column(
        children: [
          for (final goal in _goals) ...[
            _GoalCard(
              key: Key('onboarding.goal.${goal.id}'),
              title: goal.title,
              description: goal.description,
              isSelected: selected == goal.id,
              onTap: () => ref
                  .read(onboardingControllerProvider.notifier)
                  .setGoal(goal.id),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: isSelected
          ? colors.primaryContainer
          : colors.surfaceContainerHighest,
      borderRadius: AppRadii.xlR,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.xlR,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colors.onPrimaryContainer
                            : colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
