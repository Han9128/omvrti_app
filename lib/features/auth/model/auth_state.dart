// AuthState is a simple data class — it holds a snapshot of everything
// the Login and Sign Up screens need to know at any given moment.
//
// Think of it like a photograph of the auth state right now:
//   - Is an API call running?      → isLoading
//   - Did something go wrong?      → errorMessage
//   - Did the user log in?         → isAuthenticated
//
// This class is IMMUTABLE — its fields are all final.
// You never change a field directly. Instead you call copyWith()
// to produce a brand new AuthState with only the changed fields updated.
//
// Example:
//   state = state.copyWith(isLoading: true);
//   This creates a new AuthState where isLoading is true,
//   but all other fields stay exactly as they were.

class AuthState {
  // true while the login/signup API call is in progress
  // Used to show the spinner and disable the button
  final bool isLoading;

  // null  → no error, banner is hidden
  // String → error message, banner is shown with this text
  final String? errorMessage;

  // true after a successful login or signup
  // The screen watches this and navigates to /home when it becomes true
  final bool isAuthenticated;

  // const constructor — all fields required
  // We give sensible defaults so callers don't have to pass everything
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  // copyWith lets you create a new AuthState with only certain fields changed.
  //
  // The trick here is the use of a sentinel value (_undefined) instead of null.
  // Why? Because errorMessage itself can BE null (meaning "no error").
  // If we used null as the default for the errorMessage parameter, we couldn't
  // tell the difference between:
  //   "caller didn't pass errorMessage" (keep old value)
  //   "caller explicitly passed null"   (clear the error)
  //
  // The sentinel object solves this:
  //   copyWith()                          → keeps old errorMessage
  //   copyWith(errorMessage: null)        → clears errorMessage to null
  //   copyWith(errorMessage: "Bad creds") → sets new error message

  // Private sentinel — only used inside this file
  static const _undefined = Object();

  AuthState copyWith({
    bool? isLoading,
    Object? errorMessage = _undefined, // uses sentinel pattern
    bool? isAuthenticated,
  }) {
    return AuthState(
      // ?? means: use new value if provided, otherwise keep current value
      isLoading: isLoading ?? this.isLoading,

      // Sentinel check: if caller passed _undefined (default), keep old value
      // If caller passed anything else (including null), use that new value
      errorMessage: errorMessage == _undefined
          ? this.errorMessage
          : errorMessage as String?,

      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}