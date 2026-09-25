import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../motion/motion_tokens.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum MatchButtonVariant {
  primary,
  secondary,
  accent,
  outline,
  text,
}

enum MatchButtonSize {
  regular, // 52px height
  compact, // 44px height (minimum touch target standard)
  small,   // 36px height
}

class MatchButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final MatchButtonVariant variant;
  final MatchButtonSize size;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;

  const MatchButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = MatchButtonVariant.primary,
    this.size = MatchButtonSize.regular,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  State<MatchButton> createState() => _MatchButtonState();
}

class _MatchButtonState extends State<MatchButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.durationButton,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      HapticFeedback.lightImpact();
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dimensions
    double height;
    EdgeInsets padding;
    switch (widget.size) {
      case MatchButtonSize.regular:
        height = 52.0;
        padding = const EdgeInsets.symmetric(horizontal: 24);
        break;
      case MatchButtonSize.compact:
        height = 44.0;
        padding = const EdgeInsets.symmetric(horizontal: 20);
        break;
      case MatchButtonSize.small:
        height = 36.0;
        padding = const EdgeInsets.symmetric(horizontal: 14);
        break;
    }

    // Color Resolution
    Color bgColor;
    Color textColor;
    Border? border;

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    switch (widget.variant) {
      case MatchButtonVariant.primary:
        bgColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        textColor = isDark ? Colors.black : Colors.white;
        border = null;
        break;
      case MatchButtonVariant.secondary:
        bgColor = isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
        textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        border = null;
        break;
      case MatchButtonVariant.accent:
        bgColor = AppColors.accent;
        textColor = Colors.white;
        border = null;
        break;
      case MatchButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        border = Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        );
        break;
      case MatchButtonVariant.text:
        bgColor = Colors.transparent;
        textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        border = null;
        break;
    }

    if (!isEnabled && widget.variant != MatchButtonVariant.text) {
      bgColor = isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E0);
      textColor = isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA);
    }

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'please wait...',
            style: AppTypography.button(color: textColor),
          ),
        ] else ...[
          if (widget.leadingIcon != null) ...[
            widget.leadingIcon!,
            const SizedBox(width: 8),
          ],
          Text(
            widget.text.toLowerCase(),
            style: AppTypography.button(color: textColor),
          ),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: 8),
            widget.trailingIcon!,
          ],
        ],
      ],
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: MotionTokens.durationButton,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: border,
          ),
          child: content,
        ),
      ),
    );
  }
}
