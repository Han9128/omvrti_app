import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/app_button.dart';
import 'package:omvrti_app/features/auth/model/auth_state.dart';
import 'package:omvrti_app/features/auth/viewmodel/auth_viewmodel.dart';

// SignupScreen shares the same AuthState, AuthService, and AuthNotifier
// as LoginScreen — no new providers needed.
//
// This screen only needs one new file: signup_screen.dart (this file).
//
// ConsumerStatefulWidget is used because we need:
//   - 5 TextEditingControllers (must be disposed to prevent memory leaks)
//   - 2 password visibility bools (_isPasswordHidden, _isConfirmHidden)
//   - initState/dispose lifecycle methods

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // ── Controllers ────────────────────────────────────────────────────────────
  // One controller per field — all must be disposed in dispose()
  final _fullNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // ── Local state ────────────────────────────────────────────────────────────
  // Two independent toggles — password and confirm password
  // have separate show/hide states so the user can reveal
  // one without revealing the other
  bool _isPasswordHidden = true;
  bool _isConfirmHidden = true;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    // Disposing all 5 controllers is critical.
    // Each controller holds a listener on its TextField —
    // if not disposed, it keeps running even after the screen is gone,
    // slowly leaking memory with every signup screen visit.
    _fullNameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Navigation listener ────────────────────────────────────────────────────

  void _handleAuthStateChange(AuthState? previous, AuthState next) {
    // Navigate to home when signup succeeds.
    // context.go() replaces the entire stack — user cannot press
    // back to return to the signup screen after creating an account.
    if (next.isAuthenticated) {
      context.go('/home');
    }
  }

  // ── Form validation & submission ───────────────────────────────────────────

  void _handleSignUp() {
    final fullName = _fullNameController.text.trim();
    final company = _companyController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    // Clear any stale error before running fresh validation
    ref.read(authProvider.notifier).clearError();

    // Validate each field in order — stop at the first failure.
    // This gives the user one focused error to fix at a time
    // rather than showing all errors at once which is overwhelming.
    if (fullName.isEmpty) {
      _setError('Please enter your full name.');
      return;
    }
    if (fullName.length < 2) {
      _setError('Full name must be at least 2 characters.');
      return;
    }
    if (company.isEmpty) {
      _setError('Please enter your company name.');
      return;
    }
    if (email.isEmpty) {
      _setError('Please enter your work email.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _setError('Please enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      _setError('Please create a password.');
      return;
    }
    if (password.length < 6) {
      _setError('Password must be at least 6 characters.');
      return;
    }
    if (confirm.isEmpty) {
      _setError('Please confirm your password.');
      return;
    }
    if (confirm != password) {
      _setError('Passwords do not match.');
      return;
    }

    // All 8 checks passed — hand off to ViewModel
    ref.read(authProvider.notifier).signup(
          fullName: fullName,
          companyName: company,
          email: email,
          password: password,
        );
  }

  // Helper to push an error into AuthState so the error banner shows.
  // We route local validation errors through AuthState (not a separate
  // local variable) so the error banner is always in one place —
  // consistent between API errors and local validation errors.
  void _setError(String message) {
    ref.read(authProvider.notifier).state =
        ref.read(authProvider).copyWith(errorMessage: message);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Register navigation listener — runs every time AuthState changes
    ref.listen<AuthState>(authProvider, _handleAuthStateChange);

    final authState = ref.watch(authProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // false → keyboard pushes content up inside SingleChildScrollView
      // rather than resizing the whole scaffold
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // ── Illustration zone (top 40%) ───────────────────────────────────
          _buildIllustrationZone(screenHeight),

          // ── Form zone (bottom 60%) — scrollable ──────────────────────────
          _buildFormZone(authState),
        ],
      ),
    );
  }

  // ── Widget builders ────────────────────────────────────────────────────────

  Widget _buildIllustrationZone(double screenHeight) {
    return SizedBox(
      // 40% height — shorter than Login's 55% to give more room for 5 fields
      height: screenHeight * 0.40,
      width: double.infinity,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3C8F), // dark navy
              Color(0xFF2756C5), // mid blue
              Color(0xFF4A7FD4), // lighter sky blue
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),

        child: ClipRect(
          child: Stack(
            children: [
              // ── Decorative circles ────────────────────────────────────────
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 15,
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),

              // ── Subtle wave at bottom ─────────────────────────────────────
              // Creates a smooth visual merge between the gradient and the
              // white form panel below — same trick used on Login
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: const Size(double.infinity, 40),
                  painter: _WavePainter(),
                ),
              ),

              // // ── Plane silhouette ──────────────────────────────────────────
              // Positioned(
              //   top: 28,
              //   right: 22,
              //   child: Opacity(
              //     opacity: 0.88,
              //     child: Image.asset(
              //       AppImages.loginPlane,
              //       width: 130,
              //       // Graceful fallback if asset is missing
              //       errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              //     ),
              //   ),
              // ),

              // ── Title text ────────────────────────────────────────────────
              // On signup the title lives IN the illustration zone,
              // not in the form zone — this differentiates it visually
              // from Login (which shows the logo in the form zone)
              Positioned(
                bottom: 30,
                left: AppSpacing.xl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JOIN OMVRTI.AI',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white.withOpacity(0.55),
                        letterSpacing: 1.2,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Create Account',
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Start your corporate travel journey',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormZone(AuthState authState) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          // Same 32px rounded top corners as Login —
          // creates the "card sliding up" visual continuity
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),

        // SingleChildScrollView is especially important here —
        // 5 fields + button + link will overflow on smaller phones
        // when the keyboard is open without it
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Five input fields ────────────────────────────────────────
              _buildInputField(
                label: 'FULL NAME',
                controller: _fullNameController,
                hint: 'Enter your full name',
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildInputField(
                label: 'COMPANY NAME',
                controller: _companyController,
                hint: 'Enter your company name',
                prefixIcon: Icons.business_outlined,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildInputField(
                label: 'WORK EMAIL',
                controller: _emailController,
                hint: 'Enter your work email',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildInputField(
                label: 'PASSWORD',
                controller: _passwordController,
                hint: 'Create a password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _isPasswordHidden,
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                    () => _isPasswordHidden = !_isPasswordHidden,
                  ),
                  child: Icon(
                    _isPasswordHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildInputField(
                label: 'CONFIRM PASSWORD',
                controller: _confirmController,
                hint: 'Re-enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                // Independent toggle — user can reveal one but not the other
                obscureText: _isConfirmHidden,
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                    () => _isConfirmHidden = !_isConfirmHidden,
                  ),
                  child: Icon(
                    _isConfirmHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Error banner ─────────────────────────────────────────────
              // Invisible when no error, appears when validation or API fails
              _buildErrorBanner(authState.errorMessage),

              // ── Create Account button ────────────────────────────────────
              AppFilledButton(
                text: 'Create Account',
                isLoading: authState.isLoading,
                onPressed: authState.isLoading ? null : _handleSignUp,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Sign In link ─────────────────────────────────────────────
              _buildSignInLink(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable field builder ─────────────────────────────────────────────────
  //
  // Identical pattern to LoginScreen._buildInputField() — extracted the same
  // way so both screens stay consistent without duplicating InputDecoration code.
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          style: AppTextStyles.bodyMedium,

          // Clear the error banner as soon as the user starts correcting input
          onChanged: (_) => ref.read(authProvider.notifier).clearError(),

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            filled: true,
            fillColor: AppColors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.textMuted,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Error banner ───────────────────────────────────────────────────────────
  // Renders nothing when errorMessage is null.
  // Appears with a red border and icon when there is an error.
  Widget _buildErrorBanner(String? errorMessage) {
    if (errorMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: AppSpacing.sm),
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

  // ── Sign In link ───────────────────────────────────────────────────────────
  Widget _buildSignInLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            // context.pop() goes back to LoginScreen which is already in
            // the stack — cheaper and cleaner than pushing a new Login instance
            onTap: () => context.pop(),
            child: Text(
              'Sign In',
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

// ─────────────────────────────────────────────────────────────────────────────
// WAVE PAINTER
// Draws a subtle curved wave at the bottom of the illustration zone.
// Creates a smooth visual blending point between the gradient and
// the white form panel — the curve softens the hard edge.
// ─────────────────────────────────────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    // A quadratic bezier that dips down in the middle and rises at edges,
    // creating a shallow wave shape at the bottom of the illustration
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.25, size.height * 0.2, // left control point
        size.width * 0.5, size.height * 0.6,  // mid-point dip
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height,        // right control point
        size.width, size.height * 0.35,        // right edge
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}