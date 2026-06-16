import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFF00BCD4);
  static const Color secondaryLight = Color(0xFF26C6DA);
  static const Color accent = Color(0xFF00E5FF);

  // Water / Blue spectrum
  static const Color waterBlue = Color(0xFF29B6F6);
  static const Color waterDeep = Color(0xFF0277BD);
  static const Color waterLight = Color(0xFFB3E5FC);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF29B6F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [Color(0xFFF0F9FF), Color(0xFFE0F7FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF0D1117), Color(0xFF0D2137)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Light theme surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF0F9FF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE0E0E0);

  // Dark theme surfaces
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color cardDark = Color(0xFF1C2128);
  static const Color dividerDark = Color(0xFF30363D);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Text
  static const Color textPrimaryLight = Color(0xFF0D1117);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFE6EDF3);
  static const Color textSecondaryDark = Color(0xFF8B949E);

  // Glass morphism
  static const Color glassLight = Color(0x80FFFFFF);
  static const Color glassDark = Color(0x1AFFFFFF);
  static const Color glassBorderLight = Color(0x40FFFFFF);
  static const Color glassBorderDark = Color(0x26FFFFFF);

  // Streaks / Achievements
  static const Color streakGold = Color(0xFFFFD700);
  static const Color streakSilver = Color(0xFFC0C0C0);
  static const Color streakBronze = Color(0xFFCD7F32);
  static const Color streakPlatinum = Color(0xFFE5E4E2);

  // Progress ring
  static const Color progressTrackLight = Color(0xFFE0E0E0);
  static const Color progressTrackDark = Color(0xFF30363D);
}
