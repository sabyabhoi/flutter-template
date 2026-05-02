import 'package:app/src/features/shell/presentation/widgets/floating_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wraps the four bottom-tab branches with a persistent floating nav bar.
///
/// Used as the builder for the top-level [StatefulShellRoute]: the
/// [navigationShell] keeps each branch's nested navigator alive and handles
/// switching between them via [StatefulNavigationShell.goBranch].
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _items = <FloatingNavItem>[
    FloatingNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    FloatingNavItem(
      icon: Icons.apps_outlined,
      activeIcon: Icons.apps_rounded,
      label: 'Services',
    ),
    FloatingNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Activity',
    ),
    FloatingNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Account',
      showBadge: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),
          Positioned(
            left: 16,
            right: 16,
            bottom: viewPadding.bottom + 12,
            child: FloatingNavBar(
              items: _items,
              currentIndex: navigationShell.currentIndex,
              onTap: (i) => navigationShell.goBranch(
                i,
                // Tapping the active tab pops to the branch's root.
                initialLocation: i == navigationShell.currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
