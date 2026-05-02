import 'package:app/src/core/storage/prefs.dart';
import 'package:app/src/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('ThemeController', () {
    test('defaults to system when no preference is stored', () async {
      final container = await testContainer();
      addTearDown(container.dispose);

      expect(container.read(themeControllerProvider), ThemeMode.system);
    });

    test('hydrates from SharedPreferences', () async {
      final container = await testContainer(
        prefsValues: {PrefsKeys.themeMode: 'dark'},
      );
      addTearDown(container.dispose);

      expect(container.read(themeControllerProvider), ThemeMode.dark);
    });

    test('set persists to SharedPreferences', () async {
      final container = await testContainer();
      addTearDown(container.dispose);

      await container
          .read(themeControllerProvider.notifier)
          .set(ThemeMode.light);
      expect(container.read(themeControllerProvider), ThemeMode.light);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString(PrefsKeys.themeMode), 'light');
    });

    test('toggle cycles light → dark → system → light', () async {
      final container = await testContainer(
        prefsValues: {PrefsKeys.themeMode: 'light'},
      );
      addTearDown(container.dispose);

      await container.read(themeControllerProvider.notifier).toggle();
      expect(container.read(themeControllerProvider), ThemeMode.dark);

      await container.read(themeControllerProvider.notifier).toggle();
      expect(container.read(themeControllerProvider), ThemeMode.system);

      await container.read(themeControllerProvider.notifier).toggle();
      expect(container.read(themeControllerProvider), ThemeMode.light);
    });
  });
}

// Pull SharedPreferences in for the import-tracker — referenced in
// analyzer's eyes via the `prefs` variable above.
// ignore: unused_element
typedef _Keep = SharedPreferences;
