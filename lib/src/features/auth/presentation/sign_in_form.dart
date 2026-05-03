import 'package:app/src/app/router/routes.dart';
import 'package:app/src/core/error/async_value_x.dart';
import 'package:app/src/core/theme/tokens/app_spacing.dart';
import 'package:app/src/features/auth/application/auth_controller.dart';
import 'package:app/src/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Reusable sign-in form: email + password fields, primary submit, Google
/// OAuth button, and a "Sign up" link.
///
/// Owns its own [Form] and controllers but renders no [Scaffold] / [AppBar]
/// so it can be embedded inside any host (the standalone [`SignInScreen`]
/// or the final page of the onboarding flow).
class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({
    super.key,
    this.showSignUpLink = true,
  });

  /// When false, the trailing "Don't have an account? Sign up" link is
  /// hidden — useful for hosts that render their own navigation affordance
  /// (e.g. the onboarding handoff page).
  final bool showSignUpLink;

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (_, next) {
      next.showSnackBarOnError(context);
    });

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthFormField(
                    key: const Key('signIn.email'),
                    label: 'Email',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: AuthValidators.email,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AuthFormField(
                    key: const Key('signIn.password'),
                    label: 'Password',
                    controller: _passwordCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: AuthValidators.password,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FilledButton(
                    key: const Key('signIn.submit'),
                    onPressed: auth.isLoading ? null : _submit,
                    child: auth.isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AuthDivider(),
                  const SizedBox(height: AppSpacing.xl),
                  GoogleSignInButton(
                    key: const Key('signIn.google'),
                    isLoading: auth.isLoading,
                    onPressed: _signInWithGoogle,
                  ),
                  if (widget.showSignUpLink) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => context.goNamed(AppRoute.signUp.name),
                      child: const Text("Don't have an account? Sign up"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
