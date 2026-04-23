import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/autopilot/model/payment_model.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/payment_viewmodel.dart';

// PaymentScreen — shown when user taps "Proceed To Pay" on Summary Screen.
//
// Shows a breakdown of trip costs:
//   Flight + Hotel + Car Rental
//   - OmVrti Rewards Applied (discount shown in green)
//   = Total Amount
//
// "Proceed to Payment" button triggers the actual payment gateway (TODO).
//
// ConsumerStatefulWidget is used because we need local state for
// the "Total Amount" dropdown toggle (_isTotalExpanded).
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  // Controls whether the Total Amount row shows a breakdown.
  // The chevron on "Total Amount ∨" toggles this.
  // Currently just animates the chevron — breakdown can be added later.
  bool _isTotalExpanded = false;

  // Format currency as "$1,875" style
  String _formatCurrency(double amount) {
    final intAmount = amount.toInt();
    if (intAmount >= 1000) {
      final thousands = intAmount ~/ 1000;
      final remainder = intAmount % 1000;
      return '\$$thousands,${remainder.toString().padLeft(3, '0')}';
    }
    return '\$$intAmount';
  }

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
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
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

  // ── Main content ───────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context, PaymentModel payment) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                // ── Blue header card with white inner cost card ──────
                _buildPaymentCard(payment),
              ],
            ),
          ),
        ),

        // ── "Proceed to Payment" button — fixed at bottom ────────────
        _buildProceedButton(context),
      ],
    );
  }

  // ── Blue card containing the cost breakdown ────────────────────────────────
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
          // "Secure Payment" centered white title
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

          // White inner card with all cost rows
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Trip Costs" label
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Text(
                    'Trip Costs',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                // Flight row
                _buildCostRow(
                  svgPath: AppIcons.flight_takeoff,
                  iconColor: AppColors.accent,
                  label: 'Flight',
                  amount: payment.flightCost,
                ),

                // Hotel row
                _buildCostRow(
                  svgPath: AppIcons.bed_vector,
                  iconColor: const Color(0xFF4A90E2),
                  label: 'Hotel',
                  amount: payment.hotelCost,
                ),

                // Car Rental row
                _buildCostRow(
                  svgPath: AppIcons.car_rental,
                  iconColor: const Color(0xFF4A90E2),
                  label: 'Car Rental',
                  amount: payment.carRentalCost,
                ),

                // Rewards applied row — light green background
                _buildRewardsRow(payment.rewardsApplied),

                // Divider above Total Amount
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

                // Total Amount row
                _buildTotalRow(payment.totalAmount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Standard cost row: icon + label + amount right-aligned
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
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
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

  // Rewards Applied row — light green background, green text, negative amount
  Widget _buildRewardsRow(double rewardsApplied) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        // Light green background — same #E8F8EF used in Summary screen
        color: const Color(0xFFE8F8EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.omvrti_reward,
            width: 22,
            height: 22,
          ),
          const SizedBox(width: AppSpacing.sm),

          // "OmVrti.ai Rewards Applied" — mixed style text
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

          // "-$85" in green
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

  // Total Amount row — "Total Amount ∨" with chevron toggle + large bold amount
  Widget _buildTotalRow(double totalAmount) {
    return GestureDetector(
      // Tapping "Total Amount ∨" toggles the breakdown visibility
      // Currently just animates the chevron — breakdown can be added later
      onTap: () => setState(() => _isTotalExpanded = !_isTotalExpanded),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Row(
          children: [
            // "Total Amount" bold + animated chevron
            Text(
              'Total Amount',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            // Chevron rotates when expanded
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

            // Total amount — large bold
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

  // ── "Proceed to Payment" full-width red button ─────────────────────────────
  Widget _buildProceedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      color: AppColors.pageBackground,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Integrate real payment gateway (Stripe, Razorpay etc.)
          // For now show a success dialog
          _showPaymentSuccess(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Proceed to Payment',
          style: AppTextStyles.button.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Success dialog shown after tapping "Proceed to Payment"
  // Replace this with real payment gateway flow when integrating
  void _showPaymentSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Payment Successful!',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your trip has been booked successfully.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Navigate back to Home, clearing the entire booking stack
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Back to Home',
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}