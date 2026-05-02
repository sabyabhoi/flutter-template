import 'package:app/src/core/theme/tokens/app_colors.dart';
import 'package:app/src/core/theme/tokens/app_radii.dart';
import 'package:app/src/core/theme/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// Builds the app's [ThemeData] from the token layer in
/// `lib/src/core/theme/tokens/`.
///
/// To rebrand: edit [AppColors] (palette), [AppRadii] (corner family), and
/// [AppTypography] (font + scale). Every themed Material widget — buttons,
/// inputs, cards, dialogs, sheets, the floating nav bar — picks the change
/// up automatically because they all read from this builder.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light, AppColors.light);
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final scheme = _schemeFromTokens(brightness, colors);
    final textTheme = AppTypography.build(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[colors],

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.foreground,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgR),
          backgroundColor: colors.primary,
          foregroundColor: colors.primaryForeground,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgR),
          backgroundColor: colors.primary,
          foregroundColor: colors.primaryForeground,
          elevation: 0,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgR),
          foregroundColor: colors.foreground,
          side: BorderSide(color: colors.border),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgR),
          foregroundColor: colors.foreground,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.background,
        hoverColor: colors.muted,
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.mutedForeground,
        ),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: colors.foreground,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colors.mutedForeground,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.lgR,
          borderSide: BorderSide(color: colors.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgR,
          borderSide: BorderSide(color: colors.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgR,
          borderSide: BorderSide(color: colors.ring, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgR,
          borderSide: BorderSide(color: colors.destructive),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgR,
          borderSide: BorderSide(color: colors.destructive, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgR,
          borderSide: BorderSide(color: colors.input.withValues(alpha: 0.5)),
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.xlR,
          side: BorderSide(color: colors.border),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colors.popover,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.xlR),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.popoverForeground,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.popoverForeground,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.popover,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.popover,
        modalBarrierColor: Colors.black.withValues(alpha: 0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colors.secondary,
        selectedColor: colors.primary,
        disabledColor: colors.muted,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colors.secondaryForeground,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: colors.primaryForeground,
        ),
        side: BorderSide(color: colors.border),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.fullR),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.foreground,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.background,
        ),
        actionTextColor: colors.background,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgR),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
      ),

      iconTheme: IconThemeData(color: colors.foreground),
      primaryIconTheme: IconThemeData(color: colors.primaryForeground),
    );
  }

  /// Maps the semantic [AppColors] tokens onto the closest M3
  /// [ColorScheme] roles so theme-aware Material widgets get sensible
  /// defaults even when they don't read [AppColors] directly.
  static ColorScheme _schemeFromTokens(
    Brightness brightness,
    AppColors c,
  ) {
    return ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.primaryForeground,
      secondary: c.secondary,
      onSecondary: c.secondaryForeground,
      tertiary: c.accent,
      onTertiary: c.accentForeground,
      error: c.destructive,
      onError: c.destructiveForeground,
      surface: c.background,
      onSurface: c.foreground,
      surfaceContainerHighest: c.muted,
      onSurfaceVariant: c.mutedForeground,
      outline: c.border,
      outlineVariant: c.border,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: c.foreground,
      onInverseSurface: c.background,
      inversePrimary: c.primaryForeground,
    );
  }
}
