import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App typography — Inter via [GoogleFonts], wired into a complete
/// [TextTheme] so widgets that read from `Theme.of(context).textTheme`
/// automatically get the right font, size, weight, and letter spacing.
///
/// Sizes follow Material 3's natural scale (display → label) while weights
/// lean ShadCN-ish: tight letter spacing, semibold for emphasis, regular
/// for body.
abstract final class AppTypography {
  /// Builds a [TextTheme] for the given [Brightness], applying Inter to
  /// every role.
  static TextTheme build(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: _style(57, FontWeight.w700, height: 1.12, letter: -0.25),
      displayMedium: _style(45, FontWeight.w700, height: 1.16),
      displaySmall: _style(36, FontWeight.w700, height: 1.22),
      headlineLarge: _style(32, FontWeight.w700, height: 1.25),
      headlineMedium: _style(28, FontWeight.w600, height: 1.29),
      headlineSmall: _style(24, FontWeight.w600, height: 1.33),
      titleLarge: _style(22, FontWeight.w600, height: 1.27),
      titleMedium: _style(16, FontWeight.w600, height: 1.5, letter: 0.15),
      titleSmall: _style(14, FontWeight.w600, height: 1.43, letter: 0.1),
      bodyLarge: _style(16, FontWeight.w400, height: 1.5, letter: 0.5),
      bodyMedium: _style(14, FontWeight.w400, height: 1.43, letter: 0.25),
      bodySmall: _style(12, FontWeight.w400, height: 1.33, letter: 0.4),
      labelLarge: _style(14, FontWeight.w500, height: 1.43, letter: 0.1),
      labelMedium: _style(12, FontWeight.w500, height: 1.33, letter: 0.5),
      labelSmall: _style(11, FontWeight.w500, height: 1.45, letter: 0.5),
    );
  }

  static TextStyle _style(
    double size,
    FontWeight weight, {
    double? height,
    double? letter,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letter,
    );
  }
}
