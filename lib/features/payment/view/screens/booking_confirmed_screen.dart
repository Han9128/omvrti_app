// ─────────────────────────────────────────────────────────────────────────────
// BOOKING CONFIRMED SCREEN
// ─────────────────────────────────────────────────────────────────────────────
//
// Shown immediately after a successful Razorpay payment.
//
// Receives a PaymentResult object via go_router's `extra` parameter.
// Displays:
//   ✅ Animated green checkmark
//   "Booking Confirmed!" heading
//   "Payment Successful" subheading
//   Transaction ID (real payment_id from Razorpay e.g. "pay_Mfm3IasuXBs")
//   Amount paid
//   "Back to Home" button → clears navigation stack and goes to /home
//
// WHY show the real payment_id?
//   → In a demo, showing "pay_Mfm3IasuXBs" proves to stakeholders that a
//     REAL transaction happened through Razorpay — not a mocked dialog.
//   → In production, this is the reference number the traveler uses if
//     they need to contact support about their payment.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/features/payment/model/payment_result.dart';

class BookingConfirmedScreen extends StatefulWidget {
  /// The payment result passed from PaymentScreen via go_router extra.
  final PaymentResult paymentResult;

  const BookingConfirmedScreen({
    super.key,
    required this.paymentResult,
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen>
    with SingleTickerProviderStateMixin {
  // ── Animation controller for the checkmark circle ─────────────────────────
  //
  // CONCEPT: AnimationController + Tween
  //   AnimationController drives a value from 0.0 → 1.0 over a duration.
  //   We use it to animate the scale of the checkmark container,
  //   creating a satisfying "pop" effect on screen entry.
  //
  // SingleTickerProviderStateMixin provides the vsync (vertical sync) tick
  // that the AnimationController needs to know when to update.
  // Always use this mixin when you have ONE AnimationController.

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // AnimationController: drives 0→1 over 600ms
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // CurvedAnimation applies an easing curve to the linear 0→1 value.
    // elasticOut creates the "bounce" / "spring" effect — like a rubber band.
    // This is what makes the checkmark feel satisfying and alive.
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // Start the animation as soon as the screen appears
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // always dispose animation controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      // No AppBar — this is a terminal success screen.
      // The user should use "Back to Home" to exit, not the back arrow.
      // WillPopScope prevents the hardware back button from bypassing this.
      body: PopScope(
        // canPop: false — disables hardware back button.
        // The user should tap "Back to Home" which clears the nav stack properly.
        canPop: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Animated checkmark ────────────────────────────────────
                _buildAnimatedCheckmark(),
                const SizedBox(height: AppSpacing.xxl),

                // ── "Booking Confirmed!" ──────────────────────────────────
                Text(
                  'Booking Confirmed!',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Payment Successful',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Transaction details card ──────────────────────────────
                _buildTransactionCard(),

                const Spacer(flex: 3),

                // ── Back to Home button ───────────────────────────────────
                _buildHomeButton(context),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Animated bouncing checkmark ────────────────────────────────────────────
  //
  // ScaleTransition reads from _scaleAnimation (0→1 with elasticOut curve)
  // and scales the checkmark container accordingly.
  // At scale=0 it's invisible. At scale=1 it's full size.
  // elasticOut makes it overshoot slightly then settle — the "pop" effect.

  Widget _buildAnimatedCheckmark() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.12),
          shape: BoxShape.circle,
          // Outer ring using a border
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 3,
          ),
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.success,
          size: 54,
        ),
      ),
    );
  }

  // ── Transaction details card ───────────────────────────────────────────────
  //
  // Shows the real Razorpay transaction data.
  // This is what differentiates a real integration from a fake dialog:
  //   "Transaction ID: pay_Mfm3IasuXBs" → Razorpay actually processed this.

  Widget _buildTransactionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Amount paid
          _buildDetailRow(
            label: 'Amount Paid',
            value: widget.paymentResult.formattedAmount,
            valueColor: AppColors.success,
            isBold: true,
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: AppSpacing.md),

          // Transaction ID — the real Razorpay payment_id
          // This is proof that the payment went through the real gateway
          _buildDetailRow(
            label: 'Transaction ID',
            value: widget.paymentResult.paymentId,
            valueColor: AppColors.primary,
            isBold: false,
          ),

          // Order ID — only shown if we created an order (production mode)
          if (widget.paymentResult.orderId != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(
              label: 'Order ID',
              value: widget.paymentResult.orderId!,
              valueColor: AppColors.textSecondary,
              isBold: false,
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: AppSpacing.md),

          // Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Confirmed',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Detail row helper ──────────────────────────────────────────────────────

  Widget _buildDetailRow({
    required String label,
    required String value,
    required Color valueColor,
    required bool isBold,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            // Transaction IDs are long — allow wrapping
            style: AppTextStyles.bodySmall.copyWith(
              color: valueColor,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Back to Home button ────────────────────────────────────────────────────
  //
  // context.go('/home') replaces the ENTIRE navigation stack with /home.
  // This is correct — the user should NOT be able to press back and return
  // to the payment screen after a successful payment.
  //
  // context.push() would add to the stack (wrong — payment screen still there).
  // context.go()   replaces the stack (correct — clean slate).

  Widget _buildHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/home'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
        ),
        child: Text(
          'Back to Home',
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}