// AuthService is the DATA LAYER for authentication.
// Its only job is to talk to the API (or mock it for now).
//
// It knows nothing about the UI — no BuildContext, no Riverpod, no widgets.
// It just takes inputs, calls an endpoint, and returns a result.
//
// Right now it uses mock data with a fake delay (like AutopilotService).
// When the real API is ready, only this file needs to change —
// the ViewModel, State, and UI all stay exactly the same.
//
// MVVM reminder:
//   View (LoginScreen) → watches ViewModel (AuthNotifier)
//   ViewModel          → calls Service (AuthService)
//   Service            → calls API / returns data      ← you are here

// AuthResult is what the service returns after a login or signup attempt.
// It is either a success (with a token) or a failure (with an error message).
//
// This is a sealed-class-style pattern using two subclasses:
//   AuthSuccess → login/signup worked, here is the token
//   AuthFailure → something went wrong, here is why
//
// The ViewModel checks which type it got and updates AuthState accordingly.
class AuthResult {
  const AuthResult._();
}

class AuthSuccess extends AuthResult {
  // The token will be stored and sent with every subsequent API request
  // to prove the user is authenticated
  final String token;

  // The user's display name — used to personalise the home screen
  final String userName;

  const AuthSuccess({required this.token, required this.userName})
      : super._();
}

class AuthFailure extends AuthResult {
  // Human-readable error message to show in the error banner
  final String message;

  const AuthFailure({required this.message}) : super._();
}

// ─────────────────────────────────────────────────────────────────────────────

class AuthService {
  // login() simulates a POST /auth/login API call.
  //
  // Mock behaviour:
  //   email: "test@company.com" + password: "password123" → success
  //   anything else → failure with "Invalid email or password"
  //
  // Returns AuthSuccess on success, AuthFailure on failure.
  // Never throws — all errors are wrapped in AuthFailure so the
  // ViewModel doesn't need try/catch around every call.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay — remove when real API is integrated
    await Future.delayed(const Duration(seconds: 2));

    // Mock credential check — replace with real HTTP call later
    if (email == 'test@company.com' && password == 'password123') {
      return const AuthSuccess(
        token: 'mock_jwt_token_login_abc123',
        userName: 'Sam Watson',
      );
    }

    // Any other credentials fail — mirrors a real 401 Unauthorized response
    return const AuthFailure(
      message: 'Invalid email or password. Please try again.',
    );
  }

  // signup() simulates a POST /auth/signup API call.
  //
  // Mock behaviour:
  //   email: "existing@company.com" → failure (email already registered)
  //   any other email               → success
  Future<AuthResult> signup({
    required String fullName,
    required String companyName,
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock: simulate an already-registered email edge case
    // This lets us test the error banner on the Sign Up screen
    if (email == 'existing@company.com') {
      return const AuthFailure(
        message: 'An account with this email already exists.',
      );
    }

    // All other emails succeed
    return AuthSuccess(
      token: 'mock_jwt_token_signup_xyz789',
      // Use the provided name so the home screen can greet them properly
      userName: fullName,
    );
  }
}