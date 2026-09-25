import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/discovery_card_entity.dart';
import 'compatibility_badge.dart';

class DiscoveryCard extends StatefulWidget {
  final DiscoveryCardEntity card;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeUp;
  final VoidCallback onTap;

  const DiscoveryCard({
    super.key,
    required this.card,
    required this.onSwipeRight,
    required this.onSwipeLeft,
    required this.onSwipeUp,
    required this.onTap,
  });

  @override
  State<DiscoveryCard> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<DiscoveryCard> with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  late AnimationController _animController;
  late Animation<Offset> _springAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: MotionTokens.durationCard,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    if (dx > MotionTokens.swipeThresholdHorizontal) {
      _flyOff(const Offset(500, 0), widget.onSwipeRight);
    } else if (dx < -MotionTokens.swipeThresholdHorizontal) {
      _flyOff(const Offset(-500, 0), widget.onSwipeLeft);
    } else if (dy < -MotionTokens.swipeThresholdVertical) {
      _flyOff(const Offset(0, -600), widget.onSwipeUp);
    } else {
      // Spring back to center
      _springAnimation = Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
      )..addListener(() {
          setState(() {
            _dragOffset = _springAnimation.value;
          });
        });
      _animController.forward(from: 0);
    }
  }

  void _flyOff(Offset target, VoidCallback onComplete) {
    _springAnimation = Tween<Offset>(begin: _dragOffset, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {
          _dragOffset = _springAnimation.value;
        });
      });
    _animController.forward(from: 0).then((_) {
      onComplete();
      setState(() {
        _dragOffset = Offset.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final profile = card.profile;
    final photoUrl = profile.primaryPhotoUrl ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800';

    final rotationAngle = (_dragOffset.dx / 300.0) * (MotionTokens.cardMaxRotationDegrees * math.pi / 180.0);
    final likeOpacity = (_dragOffset.dx / 120.0).clamp(0.0, 1.0);
    final passOpacity = (-_dragOffset.dx / 120.0).clamp(0.0, 1.0);

    return Transform.translate(
      offset: _dragOffset,
      child: Transform.rotate(
        angle: rotationAngle,
        child: GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full-bleed Photo
                  CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFF1E1E1E),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, err) => Container(
                      color: const Color(0xFF1E1E1E),
                      child: const Icon(Icons.broken_image, color: Colors.white54),
                    ),
                  ),

                  // Bottom Vignette Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.4, 0.75, 1.0],
                          colors: [
                            Colors.transparent,
                            Color(0x99000000),
                            Color(0xEE000000),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top Compatibility Badge
                  Positioned(
                    top: 20,
                    left: 20,
                    child: CompatibilityBadge(
                      score: card.compatibilityScore,
                      reasons: card.compatibilityReasons,
                    ),
                  ),

                  // Swipe Stamps (Like / Pass)
                  if (likeOpacity > 0.05)
                    Positioned(
                      top: 40,
                      right: 28,
                      child: Opacity(
                        opacity: likeOpacity,
                        child: Transform.rotate(
                          angle: 0.15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white, width: 2.5),
                              color: Colors.black45,
                            ),
                            child: const Text(
                              'like',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (passOpacity > 0.05)
                    Positioned(
                      top: 40,
                      left: 28,
                      child: Opacity(
                        opacity: passOpacity,
                        child: Transform.rotate(
                          angle: -0.15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white60, width: 2.5),
                              color: Colors.black45,
                            ),
                            child: const Text(
                              'pass',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white60,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom Profile Information
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name and Age
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              profile.displayName.toLowerCase(),
                              style: AppTypography.displayHero(color: Colors.white).copyWith(
                                fontSize: 36,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${profile.age}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w300,
                                color: Colors.white70,
                                letterSpacing: -0.04 * 26,
                              ),
                            ),
                            if (profile.isVerified) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.verified, size: 18, color: AppColors.accent),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Curated tags
                        Text(
                          profile.interests.take(3).join('  /  ').toLowerCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            letterSpacing: -0.01 * 13,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // City & Distance
                        Row(
                          children: [
                            const Icon(Icons.place_outlined, size: 14, color: Colors.white60),
                            const SizedBox(width: 4),
                            Text(
                              '${profile.locationCity ?? "nearby"}${card.distanceKm != null ? " • ${card.distanceKm!.toStringAsFixed(1)} km" : ""}'.toLowerCase(),
                              style: const TextStyle(fontSize: 12, color: Colors.white60),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
