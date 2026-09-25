import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/network/supabase_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _authStateController = StreamController<String?>.broadcast();
  static const String _prefMockUserIdKey = 'matchstick_mock_user_id';
  static const String _prefOnboardingCompleteKey = 'matchstick_onboarding_complete_';

  String? _mockUserId;

  AuthRepositoryImpl() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _mockUserId = prefs.getString(_prefMockUserIdKey);

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      SupabaseService.client!.auth.onAuthStateChange.listen((data) {
        _authStateController.add(data.session?.user.id);
      });
    } else {
      _authStateController.add(_mockUserId);
    }
  }

  @override
  bool get isAuthenticated {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      return SupabaseService.currentUser != null;
    }
    return _mockUserId != null;
  }

  @override
  String? get currentUserId {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      return SupabaseService.currentUser?.id;
    }
    return _mockUserId;
  }

  @override
  Stream<String?> get authStateChanges => _authStateController.stream;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (SupabaseService.isInitialized && SupabaseService.client != null) {
        final res = await SupabaseService.client!.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        _authStateController.add(res.user?.id);
      } else {
        // Fallback preview mode
        await Future.delayed(const Duration(milliseconds: 600));
        _mockUserId = 'mock-user-${email.split('@')[0]}';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefMockUserIdKey, _mockUserId!);
        _authStateController.add(_mockUserId);
      }
    } catch (e) {
      throw MatchException.fromError(e);
    }
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (SupabaseService.isInitialized && SupabaseService.client != null) {
        final res = await SupabaseService.client!.auth.signUp(
          email: email.trim(),
          password: password,
        );
        _authStateController.add(res.user?.id);
      } else {
        // Fallback preview mode
        await Future.delayed(const Duration(milliseconds: 700));
        _mockUserId = 'mock-user-${email.split('@')[0]}';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefMockUserIdKey, _mockUserId!);
        _authStateController.add(_mockUserId);
      }
    } catch (e) {
      throw MatchException.fromError(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (SupabaseService.isInitialized && SupabaseService.client != null) {
        await SupabaseService.client!.auth.resetPasswordForEmail(email.trim());
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      throw MatchException.fromError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (SupabaseService.isInitialized && SupabaseService.client != null) {
        await SupabaseService.client!.auth.signOut();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefMockUserIdKey);
      _mockUserId = null;
      _authStateController.add(null);
    } catch (e) {
      throw MatchException.fromError(e);
    }
  }

  @override
  Future<bool> hasCompletedOnboarding(String userId) async {
    try {
      if (SupabaseService.isInitialized && SupabaseService.client != null) {
        final res = await SupabaseService.client!
            .from('profiles')
            .select('is_profile_complete')
            .eq('id', userId)
            .maybeSingle();
        return res != null && res['is_profile_complete'] == true;
      } else {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool('$_prefOnboardingCompleteKey$userId') ?? false;
      }
    } catch (_) {
      return false;
    }
  }

  /// Mark onboarding complete for user
  Future<void> setOnboardingComplete(String userId) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      await SupabaseService.client!
          .from('profiles')
          .update({'is_profile_complete': true})
          .eq('id', userId);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_prefOnboardingCompleteKey$userId', true);
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
