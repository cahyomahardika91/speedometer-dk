import 'package:flutter/material.dart';

/// Single source of truth for the app palette.
abstract final class AppColors {
  static const Color background = Color(0xFF05070D);
  static const Color backgroundAlt = Color(0xFF0A0F1A);
  static const Color surface = Color(0xFF101725);
  static const Color surfaceAlt = Color(0xFF161F2E);
  static const Color border = Color(0xFF1E2937);

  static const Color primary = Color(0xFF22D3EE);
  static const Color secondary = Color(0xFF818CF8);
  static const Color success = Color(0xFF2DD4BF);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF43F5E);

  static const Color textPrimary = Color(0xFFEAF2FF);
  static const Color textSecondary = Color(0xFF8B9AB1);
  static const Color textMuted = Color(0xFF5B6880);
}

abstract final class AppGradients {
  static const LinearGradient page = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFF0C1424), Color(0xFF05070D), Color(0xFF03050A)],
  );

  static const LinearGradient primary = LinearGradient(
    colors: <Color>[AppColors.primary, AppColors.success],
  );

  static const LinearGradient accent = LinearGradient(
    colors: <Color>[AppColors.primary, AppColors.secondary],
  );

  static const LinearGradient danger = LinearGradient(
    colors: <Color>[AppColors.danger, Color(0xFFFB923C)],
  );
}
