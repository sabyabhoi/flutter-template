import 'package:flutter/material.dart';

/// Shown while the auth controller's initial event is in flight, or
/// briefly during the redirect from `/` to the appropriate post-auth
/// route. Keep it lightweight.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
