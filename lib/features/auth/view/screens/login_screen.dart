import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/services/biometric_service.dart';
import 'package:omvrti_app/features/auth/model/auth_state.dart';
import 'package:omvrti_app/features/auth/viewmodel/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkExistingSession());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Runs once on screen load — mirrors WhatsApp's startup auth check.
  Future<void> _checkExistingSession() async {
    if (!mounted) return;
    final service = ref.read(biometricServiceProvider);
    final hasSession = await service.hasActiveSession();
    if (!mounted || !hasSession) return;

    final biometricEnabled = await service.isBiometricLoginEnabled();
    if (!mounted) return;

    if (biometricEnabled) {
      // Session exists + biometric enabled → auto-show scanner (no form needed)
      final success = await service.authenticateUser(
        reason: 'Sign in to OmVrti.ai',
      );
      if (success && mounted) context.go('/home');
    } else {
      // Session exists, no biometric → skip the form entirely
      context.go('/home');
    }
  }

  // Only navigate when isAuthenticated flips false → true (fresh login).
  // Guarding against previous state prevents clearError() from re-triggering
  // navigation when the user was already authenticated.
  void _handleAuthStateChange(AuthState? previous, AuthState next) {
    if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
      _onLoginSuccess();
    }
  }

  Future<void> _onLoginSuccess() async {
    final service = ref.read(biometricServiceProvider);
    final supported = await service.isDeviceSupported();
    final alreadyEnabled = await service.isBiometricLoginEnabled();

    // Show prompt if the device has biometric hardware and user hasn't opted in yet.
    // We check hardware support (not enrollment) so the prompt shows even if
    // the user hasn't enrolled fingerprints yet — they can do so after enabling.
    if (supported && !alreadyEnabled && mounted) {
      await _showEnableBiometricPrompt(service);
    }

    if (mounted) context.go('/home');
  }

  Future<void> _showEnableBiometricPrompt(BiometricService service) async {
    final label = await service.getBiometricLabel();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.fingerprint, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Enable $label Login?',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Skip the password next time — sign in instantly using $label.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  await service.enableBiometricLogin();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Enable $label',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Text(
                'Not now',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    ref.read(authProvider.notifier).clearError();

    if (email.isEmpty) {
      ref.read(authProvider.notifier).state =
          ref.read(authProvider).copyWith(errorMessage: 'Please enter your email address.');
      return;
    }

    if (password.isEmpty) {
      ref.read(authProvider.notifier).state =
          ref.read(authProvider).copyWith(errorMessage: 'Please enter your password.');
      return;
    }

    ref.read(authProvider.notifier).login(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, _handleAuthStateChange);
    final authState = ref.watch(authProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    // Logo above the card
                    _buildLogo(),

                    const SizedBox(height: 100),

                    // Login card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Center(
                              child: Text(
                                'Welcome to OmVrti.ai\nlogin now!',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.h3.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            // Center(
                            //   child: Text(
                            //     'Enter your Email and Password',
                            //     textAlign: TextAlign.center,
                            //     style: AppTextStyles.bodyMedium.copyWith(
                            //       color: AppColors.textSecondary,
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(height: 28),

                            // Error banner
                            _buildErrorBanner(authState.errorMessage),

                            // Company Email Id
                            _buildFieldLabel('Company Email Id'),
                            const SizedBox(height: 6),
                            _buildEmailField(),
                            const SizedBox(height: 20),

                            // Password
                            _buildFieldLabel('Password'),
                            const SizedBox(height: 6),
                            _buildPasswordField(),
                            const SizedBox(height: 12),

                            // Forgot Password — right aligned
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: context.push('/forgot-password')
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: authState.isLoading ? null : _handleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  disabledBackgroundColor:
                                      AppColors.accent.withValues(alpha: 0.6),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: authState.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),

                    const Spacer(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      // child: RichText(
      //   text: TextSpan(
      //     children: [
      //       TextSpan(
      //         text: 'Om',
      //         style: AppTextStyles.h1.copyWith(
      //           color: const Color(0xFF1A3C8F),
      //           fontWeight: FontWeight.w800,
      //         ),
      //       ),
      //       TextSpan(
      //         text: 'V',
      //         style: AppTextStyles.h1.copyWith(
      //           color: AppColors.accent,
      //           fontWeight: FontWeight.w800,
      //         ),
      //       ),
      //       TextSpan(
      //         text: 'rti.ai',
      //         style: AppTextStyles.h1.copyWith(
      //           color: const Color(0xFF1A3C8F),
      //           fontWeight: FontWeight.w800,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),

      child:Image.asset('assets/images/omvrti_logo.png', height: 40),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: AppTextStyles.bodyMedium,
      onChanged: (_) => ref.read(authProvider.notifier).clearError(),
      decoration: _fieldDecoration(
        hint: 'Enter your company email',
        prefixIcon: Icons.mail_outline,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _isPasswordHidden,
      style: AppTextStyles.bodyMedium,
      onChanged: (_) => ref.read(authProvider.notifier).clearError(),
      decoration: _fieldDecoration(
        hint: 'Enter your password',
        prefixIcon: Icons.lock_outline,
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
          child: Icon(
            _isPasswordHidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textMuted,
            size: 20,
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
      prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: AppColors.pageBackground,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.textMuted.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildErrorBanner(String? errorMessage) {
    if (errorMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
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
}
