import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_loading_indicator.dart';

class DiscoveryLoadingView extends StatelessWidget {
  const DiscoveryLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF263A32), Color(0xFF101A1C)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 170, 26, 116),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A BETTER WAY TO MEET',
                style: AppTypography.caption(color: Colors.white70)
                    .copyWith(letterSpacing: 2, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Finding your people',
                style: AppTypography.headingLarge(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 270),
                child: Text(
                  'Thoughtful introductions are on their way.',
                  style: AppTypography.bodyMedium(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                key: const Key('discovery-loading-preview'),
                width: 218,
                height: 218,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: -0.12,
                      child: Container(
                        width: 166,
                        height: 194,
                        decoration: BoxDecoration(
                          color: const Color(0xFF46665B),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white24),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(18, 7),
                      child: Transform.rotate(
                        angle: 0.09,
                        child: Container(
                          width: 166,
                          height: 194,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF6D8980), Color(0xFF2E4846)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white38),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x55000000),
                                blurRadius: 24,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.person_crop_circle,
                                color: Colors.white70,
                                size: 78,
                              ),
                              const SizedBox(height: 16),
                              _skeletonLine(92),
                              const SizedBox(height: 8),
                              _skeletonLine(58),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1D2C2B),
                            width: 4,
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons.heart_fill,
                          color: Colors.white,
                          size: 23,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const MatchLoadingIndicator(
                type: MatchLoadingType.dots,
                color: AppColors.accent,
              ),
              const SizedBox(height: 10),
              Text(
                'CURATING YOUR FEED',
                style: AppTypography.caption(color: Colors.white60)
                    .copyWith(letterSpacing: 1.6, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skeletonLine(double width) => Container(
    width: width,
    height: 7,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .34),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
