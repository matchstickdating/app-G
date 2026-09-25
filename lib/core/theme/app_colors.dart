import 'package:flutter/material.dart';

/// Match Stick Curated Color System
/// 
/// Philosophy: A premium neutral foundation with selective, intentional accent placement.
/// Avoids oversaturated gradients or harsh contrast.
class AppColors {
  AppColors._();

  // Primary Neutral Foundation (Light Mode)
  static const Color lightBackground = Color(0xFFF7F6F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFEFECE6);
  static const Color lightTextPrimary = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF6F6F6A);
  static const Color lightTextTertiary = Color(0xFFA5A59E);
  static const Color lightBorder = Color(0xFFE5E3DC);
  static const Color lightBorderSubtle = Color(0xFFEEECE5);

  // Primary Neutral Foundation (Dark Mode)
  static const Color darkBackground = Color(0xFF101010);
  static const Color darkSurface = Color(0xFF181818);
  static const Color darkSurfaceSubtle = Color(0xFF222222);
  static const Color darkTextPrimary = Color(0xFFF5F3ED);
  static const Color darkTextSecondary = Color(0xFFA0A09B);
  static const Color darkTextTertiary = Color(0xFF6E6E69);
  static const Color darkBorder = Color(0xFF282828);
  static const Color darkBorderSubtle = Color(0xFF1F1F1F);

  // Intentional Accent (Used sparingly, never dominant)
  static const Color accent = Color(0xFFFF5C5C);
  static const Color accentSubtle = Color(0x1AFF5C5C); // 10% opacity tint
  static const Color accentHover = Color(0xFFE64A4A);

  // System States
  static const Color success = Color(0xFF2E7D32);
  static const Color successSubtle = Color(0x182E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color warningSubtle = Color(0x18ED6C02);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorSubtle = Color(0x18D32F2F);

  // Functional Colors
  static const Color overlayDark = Color(0x73000000);
  static const Color shimmerBaseLight = Color(0xFFE0DED7);
  static const Color shimmerHighlightLight = Color(0xFFF7F6F2);
  static const Color shimmerBaseDark = Color(0xFF222222);
  static const Color shimmerHighlightDark = Color(0xFF333333);
}
