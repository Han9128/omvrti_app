import 'dart:async';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordHidden = true;

  // ── Carousel ──────────────────────────────────────────────────────────────
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _carouselTimer;

  static const _slides = [
    (image: 'assets/images/carousel/Slide1.jpg', text: 'Vertical Agentic AI\nfor Corporate Travel'),
    (image: 'assets/images/carousel/Slide2.jpg', text: 'Predictable Travel\nBudgets'),
    (image: 'assets/images/carousel/Slide3.jpg', text: 'Significant Cost Savings\nup to 40%'),
    (image: 'assets/images/carousel/Slide4.jpg', text: 'Premium, Frictionless\nBooking Experience'),
    (image: 'assets/images/carousel/Slide5.jpg', text: 'Higher Employee\nProductivity'),
    (image: 'assets/images/carousel/Slide6.jpg', text: 'Minimized\nAdministrative Overhead'),
    (image: 'assets/images/carousel/Slide7.jpg', text: 'Individually Optimized\nTravel Policies'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startCarouselTimer();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkExistingSession());
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Session / auth ────────────────────────────────────────────────────────

  Future<void> _checkExistingSession() async {
    if (!mounted) return;
    final service = ref.read(biometricServiceProvider);
    final hasSession = await service.hasActiveSession();
    if (!mounted || !hasSession) return;

    final biometricEnabled = await service.isBiometricLoginEnabled();
    if (!mounted) return;

    if (biometricEnabled) {
      final success =
          await service.authenticateUser(reason: 'Sign in to OmVrti.ai');
      if (success && mounted) context.go('/home');
    } else {
      context.go('/home');
    }
  }

  void _handleAuthStateChange(AuthState? previous, AuthState next) {
    if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
      _onLoginSuccess();
    }
  }

  Future<void> _onLoginSuccess() async {
    final service = ref.read(biometricServiceProvider);
    final supported = await service.isDeviceSupported();
    final alreadyEnabled = await service.isBiometricLoginEnabled();
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
              width: 40,
              height: 4,
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
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
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
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
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
      ref.read(authProvider.notifier).state = ref
          .read(authProvider)
          .copyWith(errorMessage: 'Please enter your username.');
      return;
    }
    if (password.isEmpty) {
      ref.read(authProvider.notifier).state = ref
          .read(authProvider)
          .copyWith(errorMessage: 'Please enter your password.');
      return;
    }
    ref.read(authProvider.notifier).login(email: email, password: password);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, _handleAuthStateChange);
    final authState = ref.watch(authProvider);

    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final carouselHeight = keyboardVisible
        ? 0.0
        : MediaQuery.of(context).size.height * 0.55;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            keyboardVisible ? Brightness.dark : Brightness.light,
        statusBarBrightness:
            keyboardVisible ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            // ── Carousel — collapses when keyboard opens ───────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              height: carouselHeight,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: _buildCarousel(context),
            ),

            // ── Scrollable form — centered in remaining space ──────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).viewInsets.bottom -
                        carouselHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo + tagline
                    Center(
                      child: Image.asset('assets/images/omvrti_logo.png',
                          height: 36),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Predictive. Personalized. Premium',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Error banner
                    _buildErrorBanner(authState.errorMessage),

                    // Username
                    _buildFieldLabel('Username'),
                    const SizedBox(height: 6),
                    _buildEmailField(),
                    const SizedBox(height: 20),

                    // Password
                    _buildFieldLabel('Password'),
                    const SizedBox(height: 6),
                    _buildPasswordField(),
                    const SizedBox(height: 10),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
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
                        onPressed:
                            authState.isLoading ? null : _handleSignIn,
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
                    const SizedBox(height: 8),
                  ],
                ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Carousel widget ───────────────────────────────────────────────────────

  Widget _buildCarousel(BuildContext context) {
    return Stack(
        fit: StackFit.expand,
        children: [
          // Slides
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => Image.asset(
              _slides[i].image,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay — dark at top & bottom for text + dots
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xBB000000),
                  Color(0x00000000),
                  Color(0x99000000),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Per-slide text overlay
          SafeArea(
            bottom: false,
            child: Align(
              alignment: const Alignment(0.0, -0.8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _slides[_currentPage].text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),

          // Dot indicators
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      );
  }

  // ── Form helpers ──────────────────────────────────────────────────────────

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
        hint: 'sam.watson',
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
        hint: 'Enter your Password',
        prefixIcon: Icons.lock_outline,
        suffixIcon: GestureDetector(
          onTap: () =>
              setState(() => _isPasswordHidden = !_isPasswordHidden),
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
      hintStyle:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
      prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
      suffixIcon: suffixIcon,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
