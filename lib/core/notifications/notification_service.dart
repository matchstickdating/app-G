import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationType {
  newMatch,
  newMessage,
  datePlanUpdate,
  verificationSuccess,
  safetyAlert,
}

class MatchNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const MatchNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    required this.timestamp,
  });
}

class NotificationService {
  final StreamController<MatchNotification> _notificationStreamController =
      StreamController<MatchNotification>.broadcast();

  Stream<MatchNotification> get onNotificationReceived =>
      _notificationStreamController.stream;

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  Future<bool> requestPermission() async {
    // In production, integrates with Firebase Messaging or OneSignal
    await Future.delayed(const Duration(milliseconds: 200));
    _hasPermission = true;
    if (kDebugMode) {
      print('MatchStick: Push notification permissions granted.');
    }
    return true;
  }

  void simulateIncomingNotification({
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) {
    final notification = MatchNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      body: body,
      data: data,
      timestamp: DateTime.now(),
    );
    _notificationStreamController.add(notification);
  }

  void dispose() {
    _notificationStreamController.close();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(() => service.dispose());
  return service;
});
