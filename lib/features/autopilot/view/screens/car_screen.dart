// ─────────────────────────────────────────────────────────────────────────────
// AUTOPILOT CAR RENTAL SCREEN
// ─────────────────────────────────────────────────────────────────────────────
//
// STEP 4 of the AutoPilot booking flow:
//   Alert → Flight → Hotel → [Car] → Summary
//
// SCREEN LAYOUT (top → bottom):
//   1. OmvrtiAppBar (showBack: true)
//   2. Blue gradient section:
//        • "Auto Pilot Booking" confirmation banner
//        • White card containing:
//            – "🚗 Car Rental" header (light blue-tinted bg)
//            – Full-width car hero image
//            – Company name + car details (left) + "In Policy" + price (right)
//            – OmVrti Rewards badge (right-aligned)
//            – Divider
//            – Spec rows: Transmission, Seats, Luggage, Drive, MPG
//   3. Fixed bottom: "Edit Car Rental" | "Confirm Booking >"
//
// DATA: carProvider → FutureProvider<CarModel>
//
// ICON COLOR NOTE:
//   All spec/amenity icons use AppColors.accent (red-orange) as per the design.
//   This is intentional — accent icons give visual contrast against the
//   white card background and are consistent with the app's brand language.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/app_button_row.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/autopilot/model/car_model.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/car_viewmodel.dart';

class AutopilotCarScreen extends ConsumerWidget {
  const AutopilotCarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch carProvider — rebuilds when AsyncValue state changes
    final carAsync = ref.watch(carProvider);

    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Back arrow — returns user to the Hotel screen
            const OmvrtiAppBar(showBack: true),

            Expanded(
              child: carAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _buildErrorState(e.toString()),
                data: (car) => _buildContent(context, car),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ERROR STATE
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MAIN CONTENT — Stack layout (scrollable + fixed bottom buttons)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, CarModel car) {
    return Stack(
      children: [
        // ── SCROLLABLE CONTENT ────────────────────────────────────────────
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            120, // Bottom padding so content clears the fixed button row
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── BLUE GRADIENT SECTION ─────────────────────────────────
              // Same gradient container used across flight and hotel screens.
              // Creates visual continuity in the AutoPilot flow.
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.pageBackground],
                    stops: const [0.0, 1.0],
                  ),
                  borderRadius: const BorderRadius.only(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBanner(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildCarCard(car),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),

        // ── FIXED BOTTOM BUTTONS ──────────────────────────────────────────
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: 24,
          child: SafeArea(
            child: AppButtonRow(
              outlinedText: 'Edit Car Rental',
              filledText: 'Confirm Booking',
              filledIcon: AppIcons.forward,
              onOutlinedPressed: () {
                // TODO: Navigate to edit car rental screen
              },
              onFilledPressed: () {
                // Confirm booking → navigate to summary screen
                context.push('/autopilot/summary');
              },
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: BANNER
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Same structure as flight and hotel banners.
  // Only the subtitle text changes to mention "transport".

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          // White circle with check — "secured" confirmation
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto Pilot Booking',
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'OmVrti.ai has secured transport for your upcoming journey',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: CAR CARD (white card with all rental details)
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Structure (top → bottom):
  //   1. "🚗 Car Rental" header (light blue-tinted background)
  //   2. Full-width car hero image
  //   3. Company name + car details (left) + price block (right)
  //   4. Rewards badge (right-aligned)
  //   5. Divider
  //   6. Car spec rows

  Widget _buildCarCard(CarModel car) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      // ClipRRect clips children to the card's rounded corners.
      // Critical for the car image — without this, it bleeds outside the card.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. "Car Rental" header ────────────────────────────────────
            _buildCardHeader(),

            // ── 2. Car hero image ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: _buildCarImage(car.imageAsset),
            ),

            // ── 3 → 6. Car details section (with padding) ─────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company name + car info (left) + price (right)
                  _buildCarNameAndPrice(car),
                  const SizedBox(height: AppSpacing.sm),

                  // Rewards badge — right-aligned
                  _buildRewardsBadge(car),
                  const SizedBox(height: AppSpacing.md),

                  // Thin separator before specs
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFEEEEEE),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // All car spec rows
                  _buildSpecsSection(car),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: "Car Rental" CARD HEADER
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Light blue-tinted strip at the top of the card.
  // [🚗 car icon]  Car Rental
  //
  // Uses a Material car icon since the design shows a simple outlined car.
  // Same light blue color as the hotel header for visual consistency.

  Widget _buildCardHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      color: const Color(0xFFF0F4FF), // Same subtle blue tint as hotel header
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.car_rental,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Car Rental',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: CAR HERO IMAGE
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Full-width, fixed-height image. BoxFit.cover fills the space cleanly.
  // Slightly taller than hotel image (200px vs 180px) because car images
  // typically need more horizontal space to look good.

  Widget _buildCarImage(String imageAsset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: SizedBox(
      width: double.infinity,
      height: 180,
      child: Image.asset(
        imageAsset,
        fit: BoxFit.contain,
        // Graceful fallback if the asset is missing during development
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFE8EAF6),
          child: const Center(
            child: Icon(
              Icons.directions_car_outlined,
              color: AppColors.textMuted,
              size: 48,
            ),
          ),
        ),
      ),
    ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: COMPANY NAME + CAR DETAILS + PRICE BLOCK
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Two-column layout:
  //
  //   LEFT (Expanded):                RIGHT (shrink-wrap):
  //   HertZ  ← bold blue, large       [✓ In Policy]
  //   Standard 2/4 Door               $65
  //   Kia K5 or Similar               per day
  //
  // Expanded on the left → long company names wrap gracefully and never
  // push the price off screen.

  Widget _buildCarNameAndPrice(CarModel car) {
    const Color policyGreen = AppColors.success;
    const Color policyGreenLight = Color(0xFFE8F5EE);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT: Rental company + car details ────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company name — bold, primary blue (matches design)
              Text(
                car.rentalCompany,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),

              // Car category: "Standard 2/4 Door"
              Text(
                car.carCategory,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Car model: "Kia K5 or Similar"
              Text(
                car.carModel,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // ── RIGHT: Policy badge + price ───────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // "In Policy" green pill — same as flight and hotel screens
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: policyGreenLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: policyGreen,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'In Policy',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: policyGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Large price — dominant visual element
            Text(
              '\$${car.pricePerDay.toStringAsFixed(0)}',
              style: AppTextStyles.price.copyWith(
                color: policyGreen,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),
            // "per day" label — matches "per night" / "round trip" style
            Text(
              'per day',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: REWARDS BADGE
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Right-aligned green pill: 🪙 $5 OmVrti Rewards
  // Identical to flight and hotel screens — pure copy for consistency.

  Widget _buildRewardsBadge(CarModel car) {
    const Color policyGreen = AppColors.success;
    const Color policyGreenLight = Color(0xFFE8F5EE);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: policyGreenLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: policyGreen, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coin SVG icon — app-wide rewards symbol
            SvgPicture.asset(
              AppIcons.omvrti_reward,
              width: 8,
              height: 28,
            ),
            const SizedBox(width: 5),

            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${car.rewardsAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.price.copyWith(
                    color: policyGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'OmVrti Rewards',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: policyGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: SPECS SECTION
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Maps over car.specs and renders each one as a _buildSpecRow().
  // Data-driven: no hardcoded rows — the list from CarModel drives the UI.
  //
  // Using .map() + spread operator (...) to insert spacing between rows:
  //   We use Padding(bottom: sm) on each row except the last, or simply
  //   wrap each in a Padding widget inside the map.

  Widget _buildSpecsSection(CarModel car) {
    return Column(
      children: car.specs.map((spec) {
        // Check if this is the last spec to avoid extra bottom padding
        final isLast = car.specs.last == spec;
        return Padding(
          padding: EdgeInsets.only(
            bottom: isLast ? 0 : AppSpacing.sm,
          ),
          child: _buildSpecRow(
            iconAsset: spec.iconAsset,
            label: spec.label,
          ),
        );
      }).toList(),
    );
  }

  // ── Single spec row ────────────────────────────────────────────────────────
  //
  // [icon]  label text
  //
  // ICON COLOR: AppColors.accent (red-orange) — as per the car rental design.
  // This is the correct color for this screen. The hotel screen used primary
  // (blue) which was a mistake — car screen uses accent red-orange per design.
  //
  // Why accent and not primary?
  // → Looking at the car rental design screenshot, the spec icons (transmission,
  //   seats, luggage etc.) are rendered in a warm red-orange tone that matches
  //   AppColors.accent. This differentiates car specs visually from flight/hotel
  //   content which uses the blue primary palette.

  Widget _buildSpecRow({
    required String iconAsset,
    required String label,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          iconAsset,
          width: 18,
          height: 18,
          colorFilter: const ColorFilter.mode(
            AppColors.accent, // ← Red-orange, as per the design (NOT blue)
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}