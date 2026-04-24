import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/core/services/biometric_service.dart';
import 'package:omvrti_app/features/auth/model/auth_state.dart';
import 'package:omvrti_app/features/auth/service/auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// In Riverpod 3.x, StateNotifierProvider is replaced by NotifierProvider.
// The Notifier class gets its dependencies via ref.read() inside methods
// instead of constructor injection.
//
// Usage in the screen:
//   final state = ref.watch(authProvider);         ← read current state
//   ref.read(authProvider.notifier).login(...)     ← call a method
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// AUTH NOTIFIER (THE VIEWMODEL)
// ─────────────────────────────────────────────────────────────────────────────

// Notifier<AuthState> replaces StateNotifier<AuthState> in Riverpod 3.x.
//   - build() returns the initial state (replaces the super() constructor call)
//   - state = ... still notifies all watchers automatically
//   - ref is available as a field — use ref.read() to access other providers
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    final result = await ref.read(authServiceProvider).login(
      email: email,
      password: password,
    );

    if (result is AuthSuccess) {
      await ref.read(biometricServiceProvider).saveSession();
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } else if (result is AuthFailure) {
      state = state.copyWith(isLoading: false, errorMessage: result.message);
    }
  }

  Future<void> signup({
    required String fullName,
    required String companyName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    final result = await ref.read(authServiceProvider).signup(
      fullName: fullName,
      companyName: companyName,
      email: email,
      password: password,
    );

    if (result is AuthSuccess) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
      );
    } else if (result is AuthFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> logout() async {
    await ref.read(biometricServiceProvider).clearSession();
    state = const AuthState();
  }
}
