import 'package:app/src/app/router/routes.dart';
import 'package:app/src/core/theme/tokens/app_spacing.dart';
import 'package:app/src/features/auth/presentation/sign_in_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Final onboarding page: embeds the reusable [SignInForm] and offers a
/// "Create account" link as a sibling action.
///
/// Reaching this page is what flips `OnboardingController.completed = true`,
/// so closing the app from here doesn't restart the tour.
class AuthHandoffPage extends StatelessWidget {
  const AuthHandoffPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.xxl,
              AppSpacing.xxl,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You’re all set',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sign in to save your progress, or create a new account.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: SignInForm(showSignUpLink: false),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            child: OutlinedButton(
              key: const Key('onboarding.createAccount'),
              onPressed: () => context.goNamed(AppRoute.signUp.name),
              child: const Text('Create a new account'),
            ),
          ),
        ],
      ),
    );
  }
}
