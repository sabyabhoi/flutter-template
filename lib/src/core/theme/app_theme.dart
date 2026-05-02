import 'package:flutter/material.dart';

/// Material 3 colour schemes and corresponding [ThemeData] for the app.
///
/// Tweak [_seedColor] (or replace with `ColorScheme.fromImageProvider` /
/// dynamic colour) to rebrand. Keep the actual `ThemeData` construction
/// here so screens never instantiate themes directly.
class AppTheme {
  AppTheme._();

  static const Color _seedColor = Color(0xFF6750A4);

  /// Shared corner radius for inputs and buttons. Kept at zero so the
  /// entire app — text fields, primary buttons, secondary buttons —
  /// reads as a single visual family instead of the default M3 mix of
  /// pill-shaped buttons against near-square inputs.
  static const BorderRadius _shapeRadius = BorderRadius.zero;
  static final RoundedRectangleBorder _shapeBorder = RoundedRectangleBorder(
    borderRadius: _shapeRadius,
  );

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
          shape: _shapeBorder,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: _shapeBorder,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: _shapeBorder,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: _shapeBorder),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: _shapeRadius),
        enabledBorder: OutlineInputBorder(borderRadius: _shapeRadius),
        focusedBorder: OutlineInputBorder(borderRadius: _shapeRadius),
        errorBorder: OutlineInputBorder(borderRadius: _shapeRadius),
        focusedErrorBorder: OutlineInputBorder(borderRadius: _shapeRadius),
        disabledBorder: OutlineInputBorder(borderRadius: _shapeRadius),
      ),
    );
  }
}
