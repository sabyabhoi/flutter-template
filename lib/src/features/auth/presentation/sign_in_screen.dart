import 'package:app/src/features/auth/presentation/sign_in_form.dart';
import 'package:flutter/material.dart';

/// Standalone sign-in route. Renders the reusable [SignInForm] inside an
/// [AppBar]+[Scaffold]. The same form is also embedded as the final page of
/// the onboarding flow.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: const SafeArea(child: SignInForm()),
    );
  }
}
