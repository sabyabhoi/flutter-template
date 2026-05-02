import 'package:flutter/material.dart';

/// Material 3 colour schemes and corresponding [ThemeData] for the app.
///
/// Tweak [_seedColor] (or replace with `ColorScheme.fromImageProvider` /
/// dynamic colour) to rebrand. Keep the actual `ThemeData` construction
/// here so screens never instantiate themes directly.
class AppTheme {
  AppTheme._();

  static const Color _seedColor = Color(0xFF6750A4);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: _seedColor);
    return _build(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    return _build(scheme);
  }

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
