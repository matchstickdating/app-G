import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum MatchAvatarSize {
  small(36),
  medium(48),
  large(72),
  hero(96);

  final double dimension;
  const MatchAvatarSize(this.dimension);
}

class MatchAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final MatchAvatarSize size;
  final bool isVerified;
  final bool isOnline;
  final VoidCallback? onTap;

  const MatchAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = MatchAvatarSize.medium,
    this.isVerified = false,
    this.isOnline = false,
    this.onTap,
  });

  String get _initials {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.trim().substring(0, name.trim().length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dim = size.dimension;

    Widget avatarContent;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: dim,
        height: dim,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildInitialsFallback(isDark, dim),
      );
    } else {
      avatarContent = _buildInitialsFallback(isDark, dim);
    }

    Widget mainWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: dim,
          height: dim,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.5,
            ),
          ),
          child: ClipOval(child: avatarContent),
        ),
        if (isVerified)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: dim * 0.28,
                height: dim * 0.28,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: dim * 0.18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        if (isOnline && !isVerified)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: dim * 0.24,
              height: dim * 0.24,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );

    if (onTap == null) return mainWidget;

    return GestureDetector(
      onTap: onTap,
      child: mainWidget,
    );
  }

  Widget _buildInitialsFallback(bool isDark, double dim) {
    return Container(
      color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
      child: Center(
        child: Text(
          _initials,
          style: AppTypography.headingSmall(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ).copyWith(
            fontSize: dim * 0.36,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
