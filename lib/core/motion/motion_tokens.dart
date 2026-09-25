import 'package:flutter/material.dart';

/// Match Stick Motion & Physics System
/// 
/// Principles:
/// - Smooth, fast, physical, and intentional
/// - Avoid sluggish transitions or gratuitous animations
/// - Respect reduced-motion accessibility
class MotionTokens {
  MotionTokens._();

  // Durations
  static const Duration durationMicro = Duration(milliseconds: 150);
  static const Duration durationButton = Duration(milliseconds: 150);
  static const Duration durationCard = Duration(milliseconds: 320);
  static const Duration durationPage = Duration(milliseconds: 380);
  static const Duration durationReveal = Duration(milliseconds: 600);
  static const Duration durationMatchBanner = Duration(milliseconds: 750);

  // Curves
  static const Curve curveStandard = Curves.fastOutSlowIn;
  static const Curve curveEnter = Curves.easeOutCubic;
  static const Curve curveExit = Curves.easeInCubic;
  static const Curve curveSpring = Curves.easeOutBack;
  static const Curve curveSmooth = Cubic(0.2, 0.0, 0.0, 1.0); // Editorial smooth decelerate

  // Card Swipe Thresholds & Physics
  static const double swipeThresholdHorizontal = 100.0;
  static const double swipeThresholdVertical = 120.0;
  static const double cardMaxRotationDegrees = 12.0;

  /// Custom PageRouteBuilder using Match Stick editorial slide & fade transition
  static PageRouteBuilder<T> editorialPageRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: durationPage,
      reverseTransitionDuration: durationPage,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curveSmooth,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
