import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum MatchTextStyle {
  hero,
  headingLarge,
  headingMedium,
  headingSmall,
  prompt,
  bodyLarge,
  bodyMedium,
  caption,
  button,
  chip,
  navigation,
}

/// Editorial Text Widget
/// Enforces intentional lowercase styling for editorial titles, consistent line heights,
/// and adaptive theme colors.
class MatchText extends StatelessWidget {
  final String text;
  final MatchTextStyle style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool forceLowercase;
  final FontWeight? fontWeight;

  const MatchText(
    this.text, {
    super.key,
    this.style = MatchTextStyle.bodyMedium,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.forceLowercase = true,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final defaultSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final defaultTertiary = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    // Apply editorial lowercase convention to headlines and titles
    final displayContent = forceLowercase &&
            (style == MatchTextStyle.hero ||
                style == MatchTextStyle.headingLarge ||
                style == MatchTextStyle.headingMedium ||
                style == MatchTextStyle.headingSmall ||
                style == MatchTextStyle.button ||
                style == MatchTextStyle.navigation)
        ? text.toLowerCase()
        : text;

    TextStyle textStyle;
    switch (style) {
      case MatchTextStyle.hero:
        textStyle = AppTypography.displayHero(color: color ?? defaultPrimary);
        break;
      case MatchTextStyle.headingLarge:
        textStyle = AppTypography.headingLarge(color: color ?? defaultPrimary);
        break;
      case MatchTextStyle.headingMedium:
        textStyle = AppTypography.headingMedium(color: color ?? defaultPrimary);
        break;
      case MatchTextStyle.headingSmall:
        textStyle = AppTypography.headingSmall(color: color ?? defaultPrimary);
        break;
      case MatchTextStyle.prompt:
        textStyle = AppTypography.promptText(color: color ?? defaultPrimary);
        break;
      case MatchTextStyle.bodyLarge:
        textStyle = AppTypography.bodyLarge(
          color: color ?? defaultPrimary,
          fontWeight: fontWeight,
        );
        break;
      case MatchTextStyle.bodyMedium:
        textStyle = AppTypography.bodyMedium(
          color: color ?? defaultSecondary,
          fontWeight: fontWeight,
        );
        break;
      case MatchTextStyle.caption:
        textStyle = AppTypography.caption(
          color: color ?? defaultTertiary,
          fontWeight: fontWeight,
        );
        break;
      case MatchTextStyle.button:
        textStyle = AppTypography.button(color: color);
        break;
      case MatchTextStyle.chip:
        textStyle = AppTypography.chip(color: color ?? defaultPrimary);
        break;
      case MatchTextStyle.navigation:
        textStyle = AppTypography.navigation(color: color ?? defaultSecondary);
        break;
    }

    return Text(
      displayContent,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
