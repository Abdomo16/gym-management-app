import 'package:flutter/material.dart';

/// Brand and semantic color tokens shared by both themes.
///
/// The look is a modern athletic SaaS palette: a near-black foundation in
/// dark mode, a high-energy accent (signal orange) for primary actions,
/// and restrained neutral surfaces with subtle borders.
abstract final class AppColors {
  // Brand — energetic accent used for primary actions and highlights.
  static const Color brand = Color(0xFFF97316);
  static const Color brandDark = Color(0xFFFB923C);

  // Semantic states.
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  // Light surface palette.
  static const Color backgroundLight = Color(0xFFF5F6F8);
  static const Color surfaceLight = Colors.white;
  static const Color borderLight = Color(0xFFE6E8EC);
  static const Color textPrimaryLight = Color(0xFF101319);
  static const Color textSecondaryLight = Color(0xFF626B7A);

  // Dark surface palette — near-black foundation with stepped surfaces.
  static const Color backgroundDark = Color(0xFF0B0D12);
  static const Color surfaceDark = Color(0xFF12151C);
  static const Color surfaceElevatedDark = Color(0xFF1A1E27);
  static const Color borderDark = Color(0xFF262B36);
  static const Color textPrimaryDark = Color(0xFFF5F6F8);
  static const Color textSecondaryDark = Color(0xFF9BA1AC);
}
