import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Match Stick Editorial Typography System
/// 
/// Powered by Google Font: Readex Pro
/// Characteristics: Geometric, minimal, lowercase editorial headings, slightly tight tracking.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Readex Pro';

  // Base font getter with Readex Pro fallback
  static TextStyle get _baseFont => GoogleFonts.readexPro();

  /// Massive Editorial Display / Hero Heading
  /// Used for punchy lowercase hero statements like "meet someone\nworth knowing."
  static TextStyle displayHero({Color? color}) {
    return _baseFont.copyWith(
      fontSize: 48,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.04 * 48, // -0.04em
      height: 0.95,
      color: color ?? AppColors.lightTextPrimary,
    );
  }

  /// Large Section Heading
  static TextStyle headingLarge({Color? color}) {
    return _baseFont.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.04 * 32,
      height: 1.05,
      color: color ?? AppColors.lightTextPrimary,
    );
  }

  /// Medium Section / Card Heading
  static TextStyle headingMedium({Color? color}) {
    return _baseFont.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.03 * 24,
      height: 1.15,
      color: color ?? AppColors.lightTextPrimary,
    );
  }

  /// Small Title / Subheading
  static TextStyle headingSmall({Color? color}) {
    return _baseFont.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.02 * 18,
      height: 1.25,
      color: color ?? AppColors.lightTextPrimary,
    );
  }

  /// Editorial Pull-Quote / Prompt Answer Style
  static TextStyle promptText({Color? color}) {
    return _baseFont.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.02 * 20,
      height: 1.35,
      color: color ?? AppColors.lightTextPrimary,
    );
  }

  /// Primary Body Text (15-16px, comfortable line height)
  static TextStyle bodyLarge({Color? color, FontWeight? fontWeight}) {
    return _baseFont.copyWith(
      fontSize: 16,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: -0.01 * 16,
      height: 1.45,
      color: color ?? AppColors.lightTextPrimary,
    );
  }

  /// Secondary Body Text (14px)
  static TextStyle bodyMedium({Color? color, FontWeight? fontWeight}) {
    return _baseFont.copyWith(
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: -0.01 * 14,
      height: 1.4,
      color: color ?? AppColors.lightTextSecondary,
    );
  }

  /// Caption / Small Helper Text (12px)
  static TextStyle caption({Color? color, FontWeight? fontWeight}) {
    return _baseFont.copyWith(
      fontSize: 12,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: -0.01 * 12,
      height: 1.3,
      color: color ?? AppColors.lightTextTertiary,
    );
  }

  /// Navigation Bar & Bottom Tabs (12-13px, lowercase, tight tracking)
  static TextStyle navigation({Color? color, bool isActive = false, FontWeight? fontWeight}) {
    return _baseFont.copyWith(
      fontSize: 12,
      fontWeight: fontWeight ?? (isActive ? FontWeight.w500 : FontWeight.w400),
      letterSpacing: -0.02 * 12,
      height: 1.2,
      color: color ?? (isActive ? AppColors.accent : AppColors.lightTextSecondary),
    );
  }

  /// Action Buttons (14px, weight 500, lowercase)
  static TextStyle button({Color? color}) {
    return _baseFont.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.02 * 14,
      height: 1.2,
      color: color ?? Colors.white,
    );
  }

  /// Interactive Tag / Chip (13px, weight 500)
  static TextStyle chip({Color? color}) {
    return _baseFont.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.01 * 13,
      height: 1.2,
      color: color ?? AppColors.lightTextPrimary,
    );
  }
}
