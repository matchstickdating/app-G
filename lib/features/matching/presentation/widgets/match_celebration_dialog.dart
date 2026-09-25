import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_button.dart';
import 'package:matchstick/features/profile/domain/entities/profile_entity.dart';

class MatchCelebrationDialog extends StatefulWidget {
  final ProfileEntity myProfile;
  final ProfileEntity matchedProfile;
  final VoidCallback onStartChat;
  final VoidCallback onKeepLooking;

  const MatchCelebrationDialog({
    super.key,
    required this.myProfile,
    required this.matchedProfile,
    required this.onStartChat,
    required this.onKeepLooking,
  });

  static Future<void> show({
    required BuildContext context,
    required ProfileEntity myProfile,
    required ProfileEntity matchedProfile,
    required VoidCallback onStartChat,
    required VoidCallback onKeepLooking,
  }) {
    HapticFeedback.heavyImpact();
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (context) => MatchCelebrationDialog(
        myProfile: myProfile,
        matchedProfile: matchedProfile,
        onStartChat: onStartChat,
        onKeepLooking: onKeepLooking,
      ),
    );
  }

  @override
  State<MatchCelebrationDialog> createState() => _MatchCelebrationDialogState();
}

class _MatchCelebrationDialogState extends State<MatchCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.durationMatchBanner,
    );

    _slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myPhoto = widget.myProfile.primaryPhotoUrl ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800';
    final matchPhoto = widget.matchedProfile.primaryPhotoUrl ??
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Converging Photos with Spring Physics
              SizedBox(
                height: 140,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // User photo (slides from left)
                      Transform.translate(
                        offset: Offset(-45 + (_slideAnimation.value * -0.5), 0),
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: _buildAvatarCircle(myPhoto),
                        ),
                      ),

                      // Matched user photo (slides from right)
                      Transform.translate(
                        offset: Offset(45 + (_slideAnimation.value * 0.5), 0),
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: _buildAvatarCircle(matchPhoto),
                        ),
                      ),

                      // Center accent spark
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent, width: 2),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 18,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Match Copy
              Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  children: [
                    Text(
                      'it\'s a match.',
                      style: AppTypography.displayHero(color: Colors.white).copyWith(
                        fontSize: 40,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'you and ${widget.matchedProfile.displayName.toLowerCase()} liked each other.\nsay hello?',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        height: 1.45,
                        letterSpacing: -0.01 * 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Actions
                    MatchButton(
                      text: 'start chatting',
                      variant: MatchButtonVariant.accent,
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onStartChat();
                      },
                    ),
                    const SizedBox(height: 12),
                    MatchButton(
                      text: 'maybe later',
                      variant: MatchButtonVariant.text,
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onKeepLooking();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatarCircle(String url) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
