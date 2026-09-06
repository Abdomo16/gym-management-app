import 'package:flutter/material.dart';

/// Brand and semantic color tokens shared by both themes.
abstract final class AppColors {
  // Brand.
  static const Color brand = Color(0xFF4F46E5);
  static const Color brandDark = Color(0xFF6366F1);

  // Semantic states.
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  // Light surface palette.
  static const Color backgroundLight = Color(0xFFF6F7F9);
  static const Color surfaceLight = Colors.white;
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Dark surface palette.
  static const Color backgroundDark = Color(0xFF0F1115);
  static const Color surfaceDark = Color(0xFF171A21);
  static const Color surfaceElevatedDark = Color(0xFF1F242E);
  static const Color borderDark = Color(0xFF2A2F3A);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
}
