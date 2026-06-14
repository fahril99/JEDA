import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const background = Color(0xFF050B14);
  static const surface = Color(0xFF0D1A2A);
  static const surfaceElevated = Color(0xFF142235);
  static const border = Color(0xFF1E3048);

  // Brand
  static const softBlue = Color(0xFF4A9EFF);
  static const emerald = Color(0xFF34D399);
  static const warningSoft = Color(0xFFFBBF24);
  static const errorSoft = Color(0xFFF87171);

  // Text
  static const textPrimary = Color(0xFFF0F6FF);
  static const textSecondary = Color(0xFF8BA3BE);
  static const textTertiary = Color(0xFF4A6480);

  // Ring
  static const ringBackground = Color(0xFF1E3048);
  static const ringProgress = Color(0xFF4A9EFF);

  // Gradients
  static const interstitialGlow = LinearGradient(
    colors: [Color(0xFF0A1828), Color(0xFF050E18)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const cardGradient = LinearGradient(
    colors: [Color(0xFF0D1A2A), Color(0xFF0A1525)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
