import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class MatchTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String hintText;
  final String? errorText;
  final bool isPassword;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final bool autoFocus;

  const MatchTextField({
    super.key,
    this.controller,
    this.label,
    required this.hintText,
    this.errorText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.autoFocus = false,
  });

  @override
  State<MatchTextField> createState() => _MatchTextFieldState();
}

class _MatchTextFieldState extends State<MatchTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!.toLowerCase(),
            style: AppTypography.caption(color: secondaryText).copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: -0.01 * 12,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: widget.controller,
          autofocus: widget.autoFocus,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onSubmitted: (_) => widget.onSubmitted?.call(),
          style: AppTypography.bodyLarge(color: primaryText),
          cursorColor: primaryText,
          decoration: InputDecoration(
            counterText: '', // Hide default ugly counter
            filled: true,
            fillColor: surfaceColor,
            hintText: widget.hintText.toLowerCase(),
            hintStyle: AppTypography.bodyLarge(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: secondaryText,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            errorText: widget.errorText,
            errorStyle: AppTypography.caption(color: AppColors.error),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryText, width: 1.5),
            ),
          ),
        ),
        if (widget.maxLength != null && widget.controller != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller!,
              builder: (context, value, _) {
                return Text(
                  '${value.text.length}/${widget.maxLength}',
                  style: AppTypography.caption(color: secondaryText),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
