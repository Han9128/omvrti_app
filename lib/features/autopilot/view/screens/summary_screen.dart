import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/autopilot/model/summary_model.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/summary_viewmodel.dart';

class AutopilotSummaryScreen extends ConsumerWidget {
  const AutopilotSummaryScreen({super.key});

  String _formatDate(DateTime date) =>
      DateFormat('EEE, MMM d, yyyy').format(date);
  String _fmt(double amount) => '\$${NumberFormat('#,##0').format(amount)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(summaryProvider);

    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const OmvrtiAppBar(showBack: true),
            Expanded(
              child: summaryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    e.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                data: (summary) => _buildContent(context, summary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MAIN CONTENT — Stack layout matching hotel/car/flight screens
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, SummaryModel summary) {
    return Stack(
      children: [
        // ── SCROLLABLE CONTENT ────────────────────────────────────────────
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            120, // space for fixed bottom buttons
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── BLUE GRADIENT SECTION ─────────────────────────────────
              // ALL cards sit inside this gradient container.
              // Gradient: primary blue (top) → pageBackground (bottom).
              // Same pattern as hotel/car/flight screens.
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.pageBackground],
                    stops: [0.0, 1.0],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.xl),
                    topRight: Radius.circular(AppSpacing.xl),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Column(
                    children: [
                      // "AutoPilot Summary" title — in the blue zone
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.lg),
                        child: Text(
                          'AutoPilot Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                      ),

                      // Purpose card
                      _buildPurposeCard(summary),
                      const SizedBox(height: AppSpacing.md),

                      // Savings card
                      _buildSavingsCard(summary),
                      const SizedBox(height: AppSpacing.md),

                      // Route + Services card
                      _buildRouteCard(summary),

                      // Bottom spacing so last card clears the gradient
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── FIXED BOTTOM BUTTONS ──────────────────────────────────────────
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: 24,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.accent,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.lg),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Edit Trip',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.lg),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Proceed To Pay',
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PURPOSE CARD
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPurposeCard(SummaryModel summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Image.asset(
              AppImages.meetingBag,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.work_outline,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purpose',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.purpose,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SAVINGS CARD
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSavingsCard(SummaryModel summary) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          // ── Congrats row — light green background ────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8EF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // SvgPicture.asset(AppIcons.rewardBadge, width: 28, height: 28),
                Image.asset(AppImages.reward_badge, width: 24, height: 24),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    "Congrats! You've Earned",
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .end, // 👈 keeps everything right aligned
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.omvrti_reward,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${summary.rewardsEarned.toStringAsFixed(0)}',
                          style: AppTextStyles.price.copyWith(
                            fontSize: 20,
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      'OmVrti Rewards',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.success,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // ── Finance rows ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            child: Column(
              children: [
                _buildFinanceRow(
                  label: 'Trip Cost',
                  value: _fmt(summary.tripCost),
                  labelBold: true,
                  valueBold: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildFinanceRow(
                  label: 'Estimated Spend',
                  value: _fmt(summary.estimatedSpend),
                  labelColor: AppColors.textSecondary,
                  valueColor: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildSavingsRow(
                  label: 'Direct Savings',
                  amount: summary.directSavings,
                  pct: summary.directSavingsPct,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildSavingsRow(
                  label: 'Overhead Savings',
                  amount: summary.overheadSavings,
                  pct: summary.overheadSavingsPct,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),

          // ── Total Company Savings — green bg ─────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8EF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Company Savings',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _fmt(summary.totalCompanySavings),
                        style: AppTextStyles.price.copyWith(
                          color: AppColors.success,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' (${summary.totalSavingsPct.toStringAsFixed(0)}%)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow({
    required String label,
    required String value,
    bool labelBold = false,
    bool valueBold = false,
    Color labelColor = AppColors.textPrimary,
    Color valueColor = AppColors.textPrimary,
    bool strikethrough = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: labelColor,
            fontWeight: labelBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w400,
            decoration: strikethrough ? TextDecoration.lineThrough : null,
            decorationColor: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsRow({
    required String label,
    required double amount,
    required double pct,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Row(
          children: [
            const Icon(
              Icons.arrow_upward_rounded,
              color: AppColors.success,
              size: 14,
            ),
            const SizedBox(width: 2),
            Text(
              '${_fmt(amount)} (${pct.toStringAsFixed(0)}%)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROUTE + SERVICES CARD
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildRouteCard(SummaryModel summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cities row ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.originCity,
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      summary.originState,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Image.asset(
                  AppImages.flightReturn,
                  width: 24,
                  height: 24,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      summary.destCity,
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      summary.destState,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Depart / Return dates ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Depart',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(summary.departDate),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Return',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(summary.returnDate),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Dashed divider + Trip Duration ───────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  'Trip Duration: ${summary.tripDuration} Days',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Hotel row ────────────────────────────────────────────────
          _buildServiceRow(
            iconAsset: AppIcons.bed_vector,
            label: 'Hotel',
            description: summary.hotelName,
            iconSize: 14,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Car Rental row ───────────────────────────────────────────
          _buildServiceRow(
            iconAsset: AppIcons.car_rental,
            label: 'Car Rental',
            description: summary.carRentalName,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow({
    required String iconAsset,
    required String label,
    required String description,
    double iconSize = 20,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          iconAsset,
          width: iconSize,
          height: iconSize,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
