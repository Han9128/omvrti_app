// ─────────────────────────────────────────────────────────────────────────────
// PAYMENT SCREEN — with Razorpay Integration
// ─────────────────────────────────────────────────────────────────────────────
//
// What changed from the original file:
//   REMOVED: _showPaymentSuccess() fake dialog
//   ADDED:   Full Razorpay SDK integration
//            → _initRazorpay()      sets up SDK + registers 3 callbacks
//            → _openRazorpay()      opens the real payment sheet
//            → _onPaymentSuccess()  handles real success with payment_id
//            → _onPaymentError()    handles failure / user cancellation
//            → _onExternalWallet()  handles Paytm, Amazon Pay etc.
//
// WHY ConsumerStatefulWidget is the RIGHT choice here:
//   Razorpay SDK requires:
//     initState() → create the Razorpay instance + register callbacks
//     dispose()   → destroy the Razorpay instance (prevent memory leaks)
//   These are LIFECYCLE METHODS — only StatefulWidget has them.
//
// PROTOTYPE FLOW:
//   User taps "Proceed to Payment"
//     → _openRazorpay() called → Razorpay sheet slides up
//     → User selects method (UPI / Card / Wallet / NetBanking) and pays
//     → _onPaymentSuccess() fires with REAL payment_id from Razorpay
//     → Navigate to BookingConfirmedScreen with the real transaction data

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/autopilot/model/payment_model.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/payment_viewmodel.dart';
import 'package:omvrti_app/features/payment/config/razorpay_config.dart';
import 'package:omvrti_app/features/payment/model/payment_result.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  // ── Razorpay SDK instance ──────────────────────────────────────────────────
  // Created once in initState, destroyed in dispose.
  // Never create this inside build() — it would be recreated on every rebuild,
  // causing duplicate event listeners and incorrect callbacks.
  late final Razorpay _razorpay;

  // Button loading state — true while Razorpay sheet is active
  bool _isProcessing = false;

  // Total amount chevron toggle — unchanged from original
  bool _isTotalExpanded = false;

  // ── initState: Create Razorpay + register event listeners ─────────────────
  @override
  void initState() {
    super.initState();
    _initRazorpay();
  }

  // ── dispose: CRITICAL — always clear Razorpay to prevent memory leaks ─────
  //
  // If you forget this, the callbacks keep firing on a dead widget.
  // Flutter will throw: "setState() called after dispose()"
  @override
  void dispose() {
    _razorpay.clear(); // unregisters all event listeners
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RAZORPAY SETUP
  // ─────────────────────────────────────────────────────────────────────────

  void _initRazorpay() {
    _razorpay = Razorpay();

    // Register all three event handlers.
    // Razorpay uses an event bus — not traditional callbacks.
    // Think: "subscribe to a channel, get notified when something happens."
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OPEN RAZORPAY
  // ─────────────────────────────────────────────────────────────────────────
  //
  // Called when user taps "Proceed to Payment".
  // Builds the options map and hands control to Razorpay SDK.
  //
  // IMPORTANT — Amount in PAISE:
  //   Razorpay works exclusively in paise (smallest Indian currency unit).
  //   1 INR = 100 paise.
  //   ₹1,875 → pass 187500 (multiply by 100, as integer).

  void _openRazorpay(double totalAmountUsd) {
    // Razorpay always works in the smallest currency unit.
    // For USD: 1 dollar = 100 cents, so multiply by 100 (same math as INR paise).
    final int amountInCents = (totalAmountUsd * 100).toInt();

    final Map<String, dynamic> options = {
      'key': RazorpayConfig.keyId,

      // ── Required fields ────────────────────────────────────────────────
      'amount': amountInCents,
      'currency': RazorpayConfig.currency, // 'USD'
      'name': RazorpayConfig.appName,
      'description': RazorpayConfig.paymentDescription,

      // ── Pre-fill traveler details ──────────────────────────────────────
      'prefill': {
        'name': 'Sam Watson',
        'email': 'sam@example.com',
        'contact': '9999999999',
      },

      // ── Brand theming ──────────────────────────────────────────────────
      'theme': {'color': RazorpayConfig.themeColor},

      // ── PRODUCTION: uncomment when backend is ready ────────────────────
      // 'order_id': orderIdFromBackend,
    };

    setState(() => _isProcessing = true);

    try {
      _razorpay.open(options);
      // From here, Razorpay takes over.
      // One of the three callbacks will fire when the user is done.
    } catch (e) {
      // open() throws if options map has invalid values
      setState(() => _isProcessing = false);
      _showSnackBar('Could not open payment. Please try again.', isError: true);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CALLBACK 1: Payment Success
  // ─────────────────────────────────────────────────────────────────────────
  //
  // Fires when the user completes payment successfully.
  //
  // PaymentSuccessResponse fields:
  //   paymentId  → real Razorpay transaction ID e.g. "pay_Mfm3IasuXBs"
  //   orderId    → null in prototype mode (no backend order was created)
  //   signature  → null in prototype mode (backend verifies this in production)
  //
  // We navigate to BookingConfirmedScreen with the real payment_id.
  // The user sees the actual transaction reference — not a fake message.

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);

    // Read current payment data to include total amount in the result
    // ref.read() used here (not watch) — we're in a callback, not build()
    final totalAmountUsd =
        ref.read(paymentProvider).value?.totalAmount ?? 0.0;

    final result = PaymentResult(
      paymentId: response.paymentId ?? 'N/A',
      orderId: response.orderId,
      signature: response.signature,
      amountPaise: (totalAmountUsd * 100).toInt(),
    );

    // Navigate to the confirmed screen, passing the result as extra data.
    // go_router's `extra` parameter is type-safe — we cast it back on the
    // receiving screen using `GoRouterState.extra as PaymentResult`.
    context.push('/payment/confirmed', extra: result);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CALLBACK 2: Payment Error / Cancellation
  // ─────────────────────────────────────────────────────────────────────────
  //
  // Fires when:
  //   → User presses back button to close payment sheet (code = PAYMENT_CANCELLED)
  //   → Card is declined (code = 2 / BAD_REQUEST_ERROR)
  //   → Network error during payment
  //   → Bank server error
  //
  // PaymentFailureResponse fields:
  //   code    → integer error code from Razorpay
  //   message → human-readable explanation

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);

    // PAYMENT_CANCELLED = user deliberately closed the sheet.
    // This is NOT an error — just reset the button silently.
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      return; // do nothing — user knows they cancelled
    }

    // Real failure — show a message so the user knows to try again
    _showSnackBar(
      response.message ?? 'Payment failed. Please try again.',
      isError: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CALLBACK 3: External Wallet
  // ─────────────────────────────────────────────────────────────────────────
  //
  // Fires when the user selects an external wallet (Paytm, Amazon Pay, etc).
  // The wallet's own app handles the payment — Razorpay notifies us of
  // the selection but not the result (the wallet app does that separately).

  void _onExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    _showSnackBar(
      'Redirecting to ${response.walletName}...',
      isError: false,
    );
  }

  // ── Snackbar helper ────────────────────────────────────────────────────────

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return; // widget might be disposed when callback fires
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
    );
  }

  // ── Currency formatter ─────────────────────────────────────────────────────

  String _formatCurrency(double amount) {
    // Format as USD: $1,234.00
    final cents = (amount * 100).round();
    final dollars = cents ~/ 100;
    final remainingCents = cents % 100;
    final centsStr = remainingCents.toString().padLeft(2, '0');
    if (dollars >= 1000) {
      final thousands = dollars ~/ 1000;
      final hundreds = (dollars % 1000).toString().padLeft(3, '0');
      return '\$$thousands,$hundreds.$centsStr';
    }
    return '\$$dollars.$centsStr';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD — UI is IDENTICAL to original. Zero visual changes.
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final paymentAsync = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            const OmvrtiAppBar(showBack: true),
            Expanded(
              child: paymentAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      error.toString(),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (payment) => _buildContent(context, payment),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaymentModel payment) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [_buildPaymentCard(payment)],
            ),
          ),
        ),
        _buildProceedButton(context, payment.totalAmount),
      ],
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.pageBackground],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.xl),
          topRight: Radius.circular(AppSpacing.xl),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Text(
              'Secure Payment',
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md,
                  ),
                  child: Text(
                    'Trip Costs',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildCostRow(
                  svgPath: AppIcons.flight_takeoff,
                  iconColor: AppColors.accent,
                  label: 'Flight',
                  amount: payment.flightCost,
                ),
                _buildCostRow(
                  svgPath: AppIcons.bed_vector,
                  iconColor: const Color(0xFF4A90E2),
                  label: 'Hotel',
                  amount: payment.hotelCost,
                ),
                _buildCostRow(
                  svgPath: AppIcons.car_rental,
                  iconColor: const Color(0xFF4A90E2),
                  label: 'Car Rental',
                  amount: payment.carRentalCost,
                ),
                _buildRewardsRow(payment.rewardsApplied),
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                _buildTotalRow(payment.totalAmount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow({
    required String svgPath,
    required Color iconColor,
    required String label,
    required double amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              svgPath,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary)),
          ),
          Text(
            _formatCurrency(amount),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsRow(double rewardsApplied) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SvgPicture.asset(AppIcons.omvrti_reward, width: 22, height: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'OmVrti.ai ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  TextSpan(
                    text: 'Rewards Applied',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            '-${_formatCurrency(rewardsApplied)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(double totalAmount) {
    return GestureDetector(
      onTap: () => setState(() => _isTotalExpanded = !_isTotalExpanded),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg,
        ),
        child: Row(
          children: [
            Text(
              'Total Amount',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _isTotalExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const Spacer(),
            Text(
              _formatCurrency(totalAmount),
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Button — only change: onPressed now calls _openRazorpay() ─────────────
  Widget _buildProceedButton(BuildContext context, double totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl,
      ),
      color: AppColors.pageBackground,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _openRazorpay(totalAmount),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.accent.withOpacity(0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Proceed to Payment',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}