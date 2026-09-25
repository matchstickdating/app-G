/// Abstract Authentication Repository Contract
abstract class AuthRepository {
  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out current user
  Future<void> signOut();

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding(String userId);

  /// Current user ID if authenticated
  String? get currentUserId;

  /// Whether a session is currently active
  bool get isAuthenticated;

  /// Stream of authentication state changes
  Stream<String?> get authStateChanges;
}
