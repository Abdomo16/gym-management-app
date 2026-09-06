import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/app/theme/app_theme.dart';
import 'package:gym_management_app/app/theme/theme_mode_provider.dart';

void main() {
  group('AppTheme', () {
    test('light and dark themes use the expected brightness', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
    });

    test('dark theme uses dark surface colors', () {
      final dark = AppTheme.dark();
      expect(dark.scaffoldBackgroundColor.computeLuminance(), lessThan(0.5));
    });

    test('theme mode maps to Material ThemeMode', () {
      expect(AppThemeMode.light.toMaterial(), ThemeMode.light);
      expect(AppThemeMode.dark.toMaterial(), ThemeMode.dark);
      expect(AppThemeMode.system.toMaterial(), ThemeMode.system);
    });
  });
}
