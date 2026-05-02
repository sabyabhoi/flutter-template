import 'package:flutter/material.dart';

/// A single tab definition for [FloatingNavBar].
class FloatingNavItem {
  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showBadge = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool showBadge;
}

/// A pill-shaped floating bottom navigation bar.
///
/// Designed to be placed inside a [Stack] (or `Scaffold.bottomNavigationBar`
/// with `extendBody: true`), floating over the body with horizontal margins
/// from the screen edges.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // A near-black surface in both themes — the floating bar reads as a
    // discrete control that sits on top of the body rather than as part of
    // it, which is the look the screenshot is going for.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark
        ? const Color(0xFF1F1F1F)
        : const Color(0xFF1F1F1F);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _NavBarItem(
                  item: items[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                  selectedColor: scheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  final FloatingNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Colors.white.withValues(alpha: 0.65);
    final color = selected ? Colors.white : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  color: color,
                  size: 23,
                ),
                if (item.showBadge)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1F1F1F),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
