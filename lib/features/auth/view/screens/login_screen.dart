import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/app_button.dart';
import 'package:omvrti_app/features/auth/model/auth_state.dart';
import 'package:omvrti_app/features/auth/viewmodel/auth_viewmodel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WHY ConsumerStatefulWidget?
// ─────────────────────────────────────────────────────────────────────────────
//
// We need BOTH StatefulWidget AND Riverpod (ConsumerWidget) here because:
//
//   StatefulWidget gives us:
//     - initState()  → set up TextEditingControllers
//     - dispose()    → clean up controllers to prevent memory leaks
//     - setState()   → toggle password visibility
//
//   ConsumerWidget gives us:
//     - ref.watch()  → rebuild UI when AuthState changes
//     - ref.read()   → call login() on the notifier
//
// ConsumerStatefulWidget combines both.
// The pattern is: class Foo extends ConsumerStatefulWidget
//                 class _FooState extends ConsumerState<Foo>
//
// Note: In ConsumerState, `ref` is already available as a property —
// you don't need to pass it through build() like in ConsumerWidget.

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ── Controllers ────────────────────────────────────────────────────────────
  // TextEditingController lets us read the current text in a TextField.
  // We create them here (not inside build) so they survive widget rebuilds.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ── Local State ────────────────────────────────────────────────────────────
  // This controls the password show/hide toggle.
  // It lives here (not in Riverpod) because it's purely local UI state —
  // no other widget needs to know about it.
  bool _isPasswordHidden = true;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    // IMPORTANT: Always dispose controllers when the widget is removed.
    // Failing to do this causes memory leaks — the controllers keep
    // listening to the text field even after the screen is gone.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Navigation Listener ────────────────────────────────────────────────────

  // _handleAuthStateChange() is called every time AuthState changes.
  // It checks if the user just successfully logged in and navigates if so.
  //
  // We use ref.listen() for navigation — NOT ref.watch() — because:
  //   ref.watch() → rebuilds the widget tree (for displaying data)
  //   ref.listen() → runs a callback (for side effects like navigation)
  //
  // Navigation is a side effect, not something to display, so listen() is right.
  void _handleAuthStateChange(AuthState? previous, AuthState next) {
    if (next.isAuthenticated) {
      // context.go() replaces the entire navigation stack with /home.
      // This means the user CANNOT press back to return to the login screen.
      // That's the correct behavior — you don't go "back" after logging in.
      context.go('/home'); // TODO: change to '/home' when Home screen is built
    }
  }

  // ── Form Validation ────────────────────────────────────────────────────────

  // _handleSignIn() runs LOCAL validation before calling the API.
  // We check fields here so we give instant feedback without a network round-trip.
  void _handleSignIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Clear any previous error before validating again
    ref.read(authProvider.notifier).clearError();

    if (email.isEmpty) {
      // setState() triggers a rebuild so the error banner shows immediately.
      // We set the error directly on the notifier so it goes through AuthState
      // and shows in the same error banner (consistent pattern).
      ref.read(authProvider.notifier).state = ref
          .read(authProvider)
          .copyWith(errorMessage: 'Please enter your email address.');
      return;
    }

    if (password.isEmpty) {
      ref.read(authProvider.notifier).state = ref
          .read(authProvider)
          .copyWith(errorMessage: 'Please enter your password.');
      return;
    }

    // All valid — hand off to the ViewModel which calls the service
    ref.read(authProvider.notifier).login(email: email, password: password);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ref.listen() registers our navigation callback.
    // It runs every time authProvider's state changes.
    // We put it inside build() — Riverpod requires listeners to be
    // registered during the build phase.
    ref.listen<AuthState>(authProvider, _handleAuthStateChange);

    // ref.watch() subscribes to AuthState.
    // Every time state changes (loading, error, success), build() reruns
    // and the UI reflects the new state automatically.
    final authState = ref.watch(authProvider);

    // MediaQuery gives us the actual screen dimensions at runtime.
    // We use this to calculate the 55% / 45% split responsively,
    // so the layout looks correct on every screen size.
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // resizeToAvoidBottomInset: false prevents the scaffold from shrinking
      // when the keyboard appears. We want the illustration to stay visible
      // while the user types — the form scrolls inside its own panel instead.
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // ── Illustration Zone (top 55%) ───────────────────────────────────
          _buildIllustrationZone(screenHeight),

          // ── Form Zone (bottom 45%) ────────────────────────────────────────
          _buildFormZone(authState),
        ],
      ),
    );
  }

  // ── Widget Builders ────────────────────────────────────────────────────────

  // The top section — gradient sky + plane + clouds
  Widget _buildIllustrationZone(double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.55,
      width: double.infinity,

      child: Container(
        decoration: const BoxDecoration(
          // LinearGradient paints a smooth color transition from top to bottom.
          // begin/end are Alignment values — topCenter = top middle of widget.
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A3C8F), // dark navy — top
              Color(0xFF2E5FB5), // mid blue
              Color(0xFF4A7FD4), // lighter sky blue — bottom
            ],
            // stops control WHERE each color sits in the gradient (0.0 to 1.0)
            stops: [0.0, 0.5, 1.0],
          ),
        ),

        // Stack lets children overlap each other freely.
        // We use Positioned inside Stack to place elements at exact spots.
        child: Stack(
          children: [
            // ── Cloud shapes ────────────────────────────────────────────────
            // Positioned fills the bottom portion of the illustration zone.
            // The clouds sit here to visually "merge" into the white form panel.
            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
            //   // Opacity wraps the clouds to make them subtle (15% visible)
            //   child: Opacity(
            //     opacity: 0.15,
            //     child: Image.asset(
            //       AppImages.loginClouds,
            //       fit: BoxFit.cover,
            //       // If asset is missing during development, show nothing
            //       errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            //     ),
            //   ),
            // ),

            // ── Plane silhouette ─────────────────────────────────────────────
            Positioned.fill(
              // top: 80,
              // right: 24,
              // child: Opacity(
              //   opacity: 0.92,
                child: Image.asset(
                  AppImages.login_trip_image,
                  fit: BoxFit.cover,
                  width: 200,
                  // If asset is missing, render nothing instead of crashing
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            // ),

            // ── "Corporate Travel" tagline ───────────────────────────────────
            // Positioned.fill makes this span the entire Stack area.
            // We then use Align to push content to the bottom-center.
            Positioned.fill(
              child: Align(
                alignment: const Alignment(0, 0.75),
                child: Text(
                  'CORPORATE TRAVEL',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white.withOpacity(0.65),
                    letterSpacing: 2.5,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The bottom section — white rounded panel with the login form
  Widget _buildFormZone(AuthState authState) {
    return Expanded(
      // Container gives us the white background and the rounded top corners
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          // BorderRadius.only lets us round ONLY the top-left and top-right.
          // The bottom corners stay square because they touch the screen edge.
          borderRadius: BorderRadius.only(
            // topLeft: Radius.circular(32),
            // topRight: Radius.circular(32),
          ),
        ),

        // SingleChildScrollView allows the form to scroll when the keyboard
        // pushes content up on smaller devices. Without this, fields near
        // the bottom could get hidden behind the keyboard.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Extra top padding to vertically center the form in the panel
              const SizedBox(height: 32),

              // ── Logo ───────────────────────────────────────────────────────
              _buildLogo(),
              const SizedBox(height: 28),

              // ── Email field ────────────────────────────────────────────────
              _buildEmailField(),
              const SizedBox(height: 16),

              // ── Password field ─────────────────────────────────────────────
              _buildPasswordField(),
              const SizedBox(height: 20),

              // ── Error banner ───────────────────────────────────────────────
              // Renders nothing (SizedBox.shrink) when errorMessage is null
              _buildErrorBanner(authState.errorMessage),

              // ── Sign In button ─────────────────────────────────────────────
              AppFilledButton(
                text: 'Sign In',
                isLoading: authState.isLoading,
                // Passing null to onPressed disables the button automatically.
                // Flutter's ElevatedButton grays itself out when null.
                onPressed: authState.isLoading ? null : _handleSignIn,
              ),

              const SizedBox(height: 16),

              // ── Forgot Password link ───────────────────────────────────────
              _buildForgotPasswordLink(),
              const SizedBox(height: 12),

              // ── Sign Up link ───────────────────────────────────────────────
              _buildSignUpLink(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Individual Section Builders ────────────────────────────────────────────

  // OmVrti.ai logo — same RichText pattern as OmvrtiAppBar
  Widget _buildLogo() {
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Om',
              style: AppTextStyles.h2.copyWith(
                color: const Color(0xFF1A3C8F),
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: 'V',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: 'rti.ai',
              style: AppTextStyles.h2.copyWith(
                color: const Color(0xFF1A3C8F),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable input field builder used by both email and password fields.
  // Extracted to avoid repeating the same InputDecoration code twice.
  //
  // Parameters:
  //   label       → the small label above the field ("EMAIL", "PASSWORD")
  //   controller  → which TextEditingController to attach
  //   hint        → placeholder text inside the field
  //   prefixIcon  → icon on the left inside the field
  //   obscureText → true for password, false for email
  //   suffixIcon  → optional widget on the right (used for eye toggle)
  //   keyboardType → determines which keyboard layout to show on mobile
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small uppercase label above the field
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),

        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,

          // Style for the text the user types
          style: AppTextStyles.bodyMedium,

          // onChanged fires every time the user types a character.
          // We use it to clear the error banner as soon as they start
          // correcting their input — better UX than keeping stale errors.
          onChanged: (_) => ref.read(authProvider.notifier).clearError(),

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),

            // Prefix icon — always visible on the left
            prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),

            // Suffix icon — only shown when provided (e.g. eye toggle)
            suffixIcon: suffixIcon,

            // contentPadding controls the space inside the field
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            // enabledBorder — how the field looks when NOT focused
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.textMuted,
                width: 1,
              ),
            ),

            // focusedBorder — how the field looks when the user taps into it
            // Blue border signals "you are currently editing this field"
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),

            // filled + fillColor gives the field a very subtle background tint
            // when focused — a standard iOS/Material pattern
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return _buildInputField(
      label: 'EMAIL',
      controller: _emailController,
      hint: 'Enter your work email',
      prefixIcon: Icons.mail_outline,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return _buildInputField(
      label: 'PASSWORD',
      controller: _passwordController,
      hint: 'Enter your password',
      prefixIcon: Icons.lock_outline,
      obscureText: _isPasswordHidden,
      // The eye icon toggle is the suffix widget
      suffixIcon: GestureDetector(
        onTap: () {
          // setState() tells Flutter to rebuild this widget with the new value.
          // Only affects _LoginScreenState — not the whole app.
          setState(() {
            _isPasswordHidden = !_isPasswordHidden;
          });
        },
        child: Icon(
          // Show "eye open" when password is hidden (tap to reveal)
          // Show "eye closed" when password is visible (tap to hide)
          _isPasswordHidden
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textMuted,
          size: 20,
        ),
      ),
    );
  }

  // Error banner — only rendered when there is an error message.
  // Returns SizedBox.shrink() (zero size, invisible) when no error.
  Widget _buildErrorBanner(String? errorMessage) {
    // If no error, return an invisible zero-height widget.
    // This is cleaner than using 'if' in the Column because the spacing
    // above/below this widget stays consistent whether it's shown or not.
    if (errorMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Very light red tint as background — not too alarming
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error icon
          Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),

          // Error message text — Expanded prevents overflow on long messages
          Expanded(
            child: Text(
              errorMessage,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: context.push('/forgot-password') when that screen is built
        },
        child: Text(
          'Forgot Password?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
            // Underline communicates this is a tappable link
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      // Row keeps "Don't have an account?" and "Sign Up" on the same line
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            // context.push() adds SignUpScreen on top of LoginScreen.
            // This means the back arrow on SignUpScreen returns here.
            onTap: () => context.push('/signup'),
            child: Text(
              'Sign Up',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}