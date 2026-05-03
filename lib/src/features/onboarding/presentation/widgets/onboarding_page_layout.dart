import 'package:app/src/core/theme/tokens/app_radii.dart';
import 'package:app/src/core/theme/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

/// Shared visual chrome for every onboarding page: hero icon block, large
/// title, subtitle, then a slot for the page-specific content.
///
/// Keeping all pages on the same skeleton avoids visual jitter as the user
/// swipes between them.
class OnboardingPageLayout extends StatelessWidget {
  const OnboardingPageLayout({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
    this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.huge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: AppRadii.xlR,
              ),
              child: Icon(
                icon,
                size: 32,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (child != null) ...[
              const SizedBox(height: AppSpacing.xxxl),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
