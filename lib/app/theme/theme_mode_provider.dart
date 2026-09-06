import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported theme modes.
///
/// Light mode is the default; dark and system modes are fully supported by
/// the theme architecture and can be enabled at any time.
enum AppThemeMode { light, dark, system }

extension AppThemeModeX on AppThemeMode {
  ThemeMode toMaterial() {
    return switch (this) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }
}

class ThemeModeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => AppThemeMode.light;

  void setMode(AppThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeController, AppThemeMode>(
  ThemeModeController.new,
);
