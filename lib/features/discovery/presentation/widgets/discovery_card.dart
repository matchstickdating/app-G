import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/widgets/profile_photo.dart';

import '../../../../core/motion/motion_tokens.dart';
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

class _DiscoveryCardState extends State<DiscoveryCard>
    with SingleTickerProviderStateMixin {
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
      _springAnimation =
          Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(
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
    _springAnimation =
        Tween<Offset>(begin: _dragOffset, end: target).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOut),
        )..addListener(() {
          setState(() {
            _dragOffset = _springAnimation.value;
          });
        });
    _animController.forward(from: 0).then((_) {
      if (!mounted) return;
      onComplete();
      if (!mounted) return;
      setState(() {
        _dragOffset = Offset.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final profile = card.profile;
    final rotation =
        (_dragOffset.dx / 300) *
        (MotionTokens.cardMaxRotationDegrees * math.pi / 180);
    final likeOpacity = (_dragOffset.dx / 120).clamp(0.0, 1.0);
    final passOpacity = (-_dragOffset.dx / 120).clamp(0.0, 1.0);
    return Transform.translate(
      offset: _dragOffset,
      child: Transform.rotate(
        angle: rotation,
        child: GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onTap: widget.onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProfilePhoto(
                url: profile.primaryPhotoUrl,
                name: profile.displayName,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, .22, .42, .72, 1],
                    colors: [
                      Color(0x73000000),
                      Colors.transparent,
                      Colors.transparent,
                      Color(0x66000000),
                      Color(0xF5101311),
                    ],
                  ),
                ),
              ),
              if (likeOpacity > .05 || passOpacity > .05)
                Positioned(
                  top: 160,
                  left: 28,
                  right: 28,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: math.max(likeOpacity, passOpacity),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            likeOpacity > passOpacity ? 'LIKE' : 'PASS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 16,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CompatibilityBadge(
                        score: card.compatibilityScore,
                        reasons: card.compatibilityReasons,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              profile.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTypography.headingLarge(
                                    color: Colors.white,
                                  ).copyWith(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1.5,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${profile.age}',
                            style:
                                AppTypography.headingLarge(
                                  color: Colors.white60,
                                ).copyWith(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -1.5,
                                ),
                          ),
                          if (profile.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ],
                        ],
                      ),
                      if (profile.interests.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: profile.interests
                                .take(3)
                                .map(
                                  (interest) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: .17,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Text(
                                      interest,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white60,
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              '${profile.locationCity ?? "Nearby"}${card.distanceKm != null ? " ? ${card.distanceKm!.toStringAsFixed(1)} km away" : ""}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _glassAction(
                            'View profile',
                            Icons.person_outline_rounded,
                            widget.onTap,
                          ),
                          _glassAction(
                            'Super like',
                            Icons.bolt_rounded,
                            widget.onSwipeUp,
                          ),
                          _glassAction(
                            'Pass',
                            Icons.close_rounded,
                            widget.onSwipeLeft,
                          ),
                          _glassAction(
                            'Like',
                            Icons.favorite_rounded,
                            widget.onSwipeRight,
                            primary: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassAction(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool primary = false,
  }) {
    return Material(
      color: primary
          ? const Color(0xFFFF3990)
          : Colors.white.withValues(alpha: .19),
      shape: CircleBorder(
        side: BorderSide(color: primary ? Colors.transparent : Colors.white24),
      ),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        onPressed: onTap,
        constraints: const BoxConstraints(minWidth: 54, minHeight: 54),
        icon: Icon(icon, size: 26, color: Colors.white),
        tooltip: label,
      ),
    );
  }
}
