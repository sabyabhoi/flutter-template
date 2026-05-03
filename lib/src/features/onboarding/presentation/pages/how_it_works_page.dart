import 'package:app/src/core/theme/tokens/app_radii.dart';
import 'package:app/src/core/theme/tokens/app_spacing.dart';
import 'package:app/src/features/onboarding/presentation/widgets/onboarding_page_layout.dart';
import 'package:flutter/material.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageLayout(
      icon: Icons.lightbulb_outline,
      title: 'How it works',
      subtitle: 'Three quick ideas to keep in mind as you start using the app.',
      child: Column(
        children: [
          _FeatureRow(
            icon: Icons.bolt_outlined,
            title: 'Fast by default',
            description: 'Optimised for quick actions, not endless menus.',
          ),
          SizedBox(height: AppSpacing.lg),
          _FeatureRow(
            icon: Icons.lock_outline,
            title: 'Yours alone',
            description: 'Your data stays on-device until you choose to sync.',
          ),
          SizedBox(height: AppSpacing.lg),
          _FeatureRow(
            icon: Icons.tune_outlined,
            title: 'Tailored to you',
            description: "We'll use the next few answers to set things up.",
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: AppRadii.lgR,
          ),
          child: Icon(icon, size: 20, color: colors.onSurface),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
