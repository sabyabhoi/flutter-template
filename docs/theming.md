# Theming

Theming is built on a token layer (`AppColors` `ThemeExtension`, `AppTypography`, `AppRadii`, `AppSpacing`) that an `AppTheme` builder maps onto Material 3 `ColorScheme` roles. A `ThemeController` Riverpod notifier persists the user's `ThemeMode` to `SharedPreferences`. Material 3 is enabled, but the palette is **not** seeded — semantic tokens are explicit hex colors borrowed from ShadCN's "zinc" theme.

## Files

| File | Description |
| --- | --- |
| [`lib/src/core/theme/app_theme.dart`](../lib/src/core/theme/app_theme.dart) | `AppTheme.light()` / `AppTheme.dark()` build the `ThemeData` and component themes. |
| [`lib/src/core/theme/theme_controller.dart`](../lib/src/core/theme/theme_controller.dart) | `ThemeController` notifier persisting `ThemeMode`. Generated `theme_controller.g.dart` exposes `themeControllerProvider`. |
| [`lib/src/core/theme/tokens/app_colors.dart`](../lib/src/core/theme/tokens/app_colors.dart) | `AppColors` `ThemeExtension` (light + dark palettes) + `AppColorsContextX.appColors`. |
| [`lib/src/core/theme/tokens/app_typography.dart`](../lib/src/core/theme/tokens/app_typography.dart) | `AppTypography.build(brightness)` — Inter via `google_fonts`, Material-3 sized scale. |
| [`lib/src/core/theme/tokens/app_radii.dart`](../lib/src/core/theme/tokens/app_radii.dart) | Corner radius scale (`xs` → `xxl` + `full`) plus matching `BorderRadius` constants. |
| [`lib/src/core/theme/tokens/app_spacing.dart`](../lib/src/core/theme/tokens/app_spacing.dart) | Spacing scale (`xs` → `huge`) for paddings, gaps, insets. |

## Tokens

### `AppColors`

[`AppColors`](../lib/src/core/theme/tokens/app_colors.dart) is a `ThemeExtension<AppColors>` modeled after ShadCN CSS variables (`background`, `foreground`, `card`, `popover`, `primary`, `secondary`, `muted`, `accent`, `destructive`, `border`, `input`, `ring`, plus `*-foreground` pairs). The `light` and `dark` palettes are the ShadCN "zinc" theme.

Two ways to read tokens from a widget:

1. **Through M3 roles.** `AppTheme._schemeFromTokens` maps tokens onto `ColorScheme` slots, so any Material widget that reads `Theme.of(context).colorScheme.primary` etc. picks up the right value automatically.
2. **Directly.** Tokens that don't have a natural M3 home — `card`, `popover`, `border`, `ring` — are read via the `BuildContext` extension:
   ```dart
   final c = context.appColors;
   c.border; c.ring; c.card; c.popover; ...
   ```
   Defined as `extension AppColorsContextX on BuildContext` in [`app_colors.dart`](../lib/src/core/theme/tokens/app_colors.dart).

This is the **only** place hex values for the app palette should live — never inline `Color(0xFF…)` in widget code.

### `AppTypography`

[`AppTypography.build(Brightness)`](../lib/src/core/theme/tokens/app_typography.dart) returns a complete `TextTheme`. Inter is loaded via `google_fonts` and applied to the dark / light Mountain View base. Sizes follow Material 3's natural scale (`displayLarge` 57 down to `labelSmall` 11), with semibold (`w600`) for titles/headlines and regular (`w400`) for body. Letter spacing follows the M3 numeric defaults.

Anything that reads `Theme.of(context).textTheme.<x>` automatically gets the right font/weight/size/letter spacing.

### `AppRadii`

[`AppRadii`](../lib/src/core/theme/tokens/app_radii.dart) — `xs (2)`, `sm (4)`, `md (6)`, `lg (8)`, `xl (12)`, `xxl (16)`, `full (9999)`. Each step has both a `double` and a `BorderRadius.all(Radius.circular(...))` constant (suffix `R`).

Conventions used in [`AppTheme`](../lib/src/core/theme/app_theme.dart):

- `lg` (8) — buttons, inputs, smaller chips, SnackBars.
- `xl` (12) — cards, sheets, dialogs, the floating nav bar pill.
- `full` — circular ends (chips, avatars).

### `AppSpacing`

[`AppSpacing`](../lib/src/core/theme/tokens/app_spacing.dart) — `xs (4)`, `sm (8)`, `md (12)`, `lg (16)`, `xl (20)`, `xxl (24)`, `xxxl (32)`, `huge (40)`. Use these instead of raw doubles for paddings/insets/gaps.

## `AppTheme`

[`AppTheme`](../lib/src/core/theme/app_theme.dart) is a private constructor with two static factories — `light()` and `dark()` — plus a private `_build(Brightness, AppColors)` that does the work.

It enables Material 3 and configures **explicit component themes** for:

| Component | Notes |
| --- | --- |
| `AppBarTheme` | Transparent surface tint, no elevation, no center-title. Title uses `textTheme.titleLarge`. |
| `FilledButtonTheme` / `ElevatedButtonTheme` | `Size.fromHeight(48)`, `AppRadii.lgR`, `colors.primary` / `primaryForeground`. |
| `OutlinedButtonTheme` / `TextButtonTheme` | `colors.foreground`, `colors.border`, `AppRadii.lgR`. |
| `InputDecorationTheme` | Filled, `colors.input` border, `colors.ring` (1.5px) when focused, `colors.destructive` on error. |
| `CardTheme` | `colors.card`, no elevation/tint, `AppRadii.xlR` outline using `colors.border`. |
| `DialogTheme` | `colors.popover` background, `AppRadii.xlR`. |
| `BottomSheetTheme` | `colors.popover`, top corners `AppRadii.xl`, modal scrim 50% black. |
| `ChipTheme` | `colors.secondary` background, `colors.primary` selected, `AppRadii.fullR` (pill). |
| `DividerTheme` | `colors.border`, 1px. |
| `SnackBarTheme` | `colors.foreground` background (inverted text), floating, `AppRadii.lgR`. |
| `ProgressIndicatorTheme` | `colors.primary`. |
| `IconTheme` / `primaryIconTheme` | `colors.foreground` / `colors.primaryForeground`. |

`extensions: <ThemeExtension<dynamic>>[colors]` registers the `AppColors` instance so `context.appColors` works from any descendant.

### `_schemeFromTokens(Brightness, AppColors)`

The ShadCN tokens are mapped onto `ColorScheme` roles manually:

| Token | `ColorScheme` slot |
| --- | --- |
| `primary` / `primaryForeground` | `primary` / `onPrimary` |
| `secondary` / `secondaryForeground` | `secondary` / `onSecondary` |
| `accent` / `accentForeground` | `tertiary` / `onTertiary` |
| `destructive` / `destructiveForeground` | `error` / `onError` |
| `background` / `foreground` | `surface` / `onSurface` |
| `muted` / `mutedForeground` | `surfaceContainerHighest` / `onSurfaceVariant` |
| `border` | `outline` and `outlineVariant` |
| `foreground` / `background` | `inverseSurface` / `onInverseSurface` |
| `primaryForeground` | `inversePrimary` |
| `Colors.black` | `shadow`, `scrim` |

> Material 3 is enabled (`useMaterial3: true`) but **`ColorScheme.fromSeed` is not used**. The palette is the explicit hex ShadCN one, not a dynamically generated tonal palette. To rebrand, edit [`AppColors`](../lib/src/core/theme/tokens/app_colors.dart) (or replace `_schemeFromTokens` with `ColorScheme.fromSeed(...)` if you want dynamic-color behavior).

## `ThemeController`

[`ThemeController`](../lib/src/core/theme/theme_controller.dart) is a `@riverpod` notifier returning `ThemeMode`. It reads/writes the user's selection through `PrefsKeys.themeMode` on the shared `SharedPreferences` instance.

| Member | Behavior |
| --- | --- |
| `build()` | Reads `prefs.getString(PrefsKeys.themeMode)`, returns `_decode(stored)`. Default = `ThemeMode.system` if unset/unknown. |
| `Future<void> set(ThemeMode mode)` | Writes the encoded string and updates `state`. |
| `Future<void> toggle()` | Cycles **light → dark → system → light**. |

Encoding is `light` / `dark` / `system`. The `_decode` helper falls back to `system` for any other value (including `null`).

[`SettingsScreen`](../lib/src/features/settings/presentation/settings_screen.dart) is the main consumer — three `RadioListTile<ThemeMode>` bound to `themeControllerProvider.notifier.set(...)`. The root [`App`](../lib/src/app/app.dart) widget passes the current `themeMode` straight to `MaterialApp.router(themeMode: ...)`.

## Persistence

`PrefsKeys.themeMode` is `'app.theme_mode'`. Defined alongside the other reserved keys (`onboardingComplete`, `localeTag`) in [`prefs.dart`](../lib/src/core/storage/prefs.dart). See [`storage.md`](storage.md).

## See also

- [`storage.md`](storage.md) — `sharedPreferencesProvider` + `PrefsKeys` + the override-in-bootstrap pattern.
- [`testing.md`](testing.md) — `theme_controller_test.dart` covers the cycle, defaults, and persistence.
- [`routing-and-shell.md`](routing-and-shell.md) — `FloatingNavBar` is one of the main consumers of `context.appColors` + `AppRadii`.
