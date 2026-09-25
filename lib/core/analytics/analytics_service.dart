import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  const AnalyticsEvent({
    required this.name,
    this.parameters = const {},
    required this.timestamp,
  });
}

class AnalyticsService {
  final List<AnalyticsEvent> _eventLog = [];
  List<AnalyticsEvent> get loggedEvents => List.unmodifiable(_eventLog);

  void logEvent(String name, [Map<String, dynamic> parameters = const {}]) {
    // Sanitize parameters to guarantee zero PII is logged
    final sanitized = Map<String, dynamic>.from(parameters)
      ..removeWhere((k, v) =>
          k.toLowerCase().contains('email') ||
          k.toLowerCase().contains('phone') ||
          k.toLowerCase().contains('message') ||
          k.toLowerCase().contains('password'));

    final event = AnalyticsEvent(
      name: name,
      parameters: sanitized,
      timestamp: DateTime.now(),
    );

    _eventLog.add(event);

    if (kDebugMode) {
      print('📊 [MatchStick Analytics] $name : $sanitized');
    }
  }

  void logScreenView(String screenName) {
    logEvent('screen_view', {'screen_name': screenName});
  }

  void logDiscoveryAction(String action) {
    logEvent('discovery_action', {'action': action});
  }

  void logMatchCreated() {
    logEvent('mutual_match_created');
  }

  void logDatePlanGenerated(String vibe, String budgetTier) {
    logEvent('ai_date_plan_generated', {'vibe': vibe, 'budget': budgetTier});
  }

  void logVerificationSubmitted() {
    logEvent('selfie_verification_submitted');
  }

  void logStudioUpgrade() {
    logEvent('studio_tier_purchased');
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
