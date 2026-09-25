import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../data/repositories/auth_repository_impl.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  onboardingRequired,
  authenticated,
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final repo = AuthRepositoryImpl();
  ref.onDispose(repo.dispose);
  return repo;
});

class AuthController extends Notifier<AuthState> {
  AuthRepositoryImpl get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    Future.microtask(_checkInitialState);
    return const AuthState(status: AuthStatus.initial);
  }

  Future<void> _checkInitialState() async {
    state = state.copyWith(isLoading: true);
    final userId = _repository.currentUserId;
    if (userId != null) {
      final hasCompleted = await _repository.hasCompletedOnboarding(userId);
      state = state.copyWith(
        status: hasCompleted ? AuthStatus.authenticated : AuthStatus.onboardingRequired,
        userId: userId,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.signInWithEmail(email: email, password: password);
      final userId = _repository.currentUserId;
      final hasCompleted = userId != null ? await _repository.hasCompletedOnboarding(userId) : false;

      state = state.copyWith(
        status: hasCompleted ? AuthStatus.authenticated : AuthStatus.onboardingRequired,
        userId: userId,
        isLoading: false,
      );
      return true;
    } on MatchException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.userMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'something went sideways. try again in a moment.',
      );
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.signUpWithEmail(email: email, password: password);
      final userId = _repository.currentUserId;

      state = state.copyWith(
        status: AuthStatus.onboardingRequired,
        userId: userId,
        isLoading: false,
      );
      return true;
    } on MatchException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.userMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'something went sideways. try again in a moment.',
      );
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } on MatchException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.userMessage);
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    final userId = state.userId;
    if (userId != null) {
      await _repository.setOnboardingComplete(userId);
    }
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
