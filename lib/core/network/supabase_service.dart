import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Initialize Supabase client.
  /// If credentials are missing or invalid, initializes gracefully in mock/offline mode.
  static Future<void> initialize({
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) async {
    final url = supabaseUrl ??
        const String.fromEnvironment(AppConstants.supabaseUrlEnv, defaultValue: '');
    final anonKey = supabaseAnonKey ??
        const String.fromEnvironment(AppConstants.supabaseAnonKeyEnv, defaultValue: '');

    if (url.isNotEmpty && anonKey.isNotEmpty && !url.contains('dummy')) {
      try {
        await Supabase.initialize(
          url: url,
          publishableKey: anonKey,
          debug: kDebugMode,
        );
        _isInitialized = true;
        debugPrint('[Matchstick] Supabase connected successfully to $url');
      } catch (e) {
        debugPrint('[Matchstick] Supabase init failed: $e. Running in standalone mode.');
        _isInitialized = false;
      }
    } else {
      debugPrint('[Matchstick] No Supabase credentials configured. Running in offline/preview mode.');
      _isInitialized = false;
    }
  }

  /// Get active Supabase client instance if initialized
  static SupabaseClient? get client {
    if (_isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Current user if authenticated
  static User? get currentUser => client?.auth.currentUser;

  /// Check if user session exists
  static bool get isAuthenticated => currentUser != null;
}

/// Riverpod provider for Supabase client
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  return SupabaseService.client;
});

/// Riverpod provider for current authenticated user
final currentUserProvider = Provider<User?>((ref) {
  return SupabaseService.currentUser;
});
