// ─────────────────────────────────────────────────────────────────────────────
// AUTOPILOT HOTEL SCREEN
// ─────────────────────────────────────────────────────────────────────────────
//
// STEP 3 of the AutoPilot booking flow:
//   Alert → Flight → [Hotel] → Car → Summary
//
// SCREEN LAYOUT (top → bottom):
//   1. OmvrtiAppBar (showBack: true — back arrow on left)
//   2. Blue gradient section (same pattern as flight screen):
//        • "Auto Pilot Booking" confirmation banner
//        • White card containing:
//            – "Stay at New York" header
//            – Full-width hotel hero image
//            – Hotel name + area + "In Policy" badge + price
//            – OmVrti Rewards badge
//            – Divider
//            – Amenity rows (check-in, check-out, parking, breakfast, stars, walk)
//   3. Fixed bottom button row: "Edit Hotel" | "View Car Rental >"
//
// DATA:
//   • hotelProvider → FutureProvider<HotelModel>
//
// PATTERN NOTE:
//   This screen intentionally mirrors autopilot_flight_screen.dart in
//   structure: same Stack layout (scrollable content + fixed bottom buttons),
//   same blue gradient banner, same error/loading states.
//   Consistency across screens makes the codebase easier to maintain.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/utils/formatters.dart';
import 'package:omvrti_app/core/widgets/app_button_row.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/autopilot/model/hotel_model.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/hotel_viewmodel.dart';

class AutopilotHotelScreen extends ConsumerWidget {
  const AutopilotHotelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the hotelProvider. This triggers a rebuild whenever the
    // AsyncValue state changes (loading → data, or loading → error).
    final hotelAsync = ref.watch(hotelProvider);

    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Back arrow — returns user to the Flight screen
            const OmvrtiAppBar(showBack: true),

            // Expanded fills the remaining vertical space below the AppBar.
            // Without it, Column would shrink-wrap and the screen would look broken.
            Expanded(
              child: hotelAsync.when(
                // ── Loading state ─────────────────────────────────────────
                loading: () =>
                    const Center(child: CircularProgressIndicator()),

                // ── Error state ───────────────────────────────────────────
                error: (e, _) => _buildErrorState(e.toString()),

                // ── Success state ─────────────────────────────────────────
                data: (hotel) => _buildContent(context, hotel),
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
  // Reusable error widget. Centered on screen with icon + message.
  // Identical pattern to flight screen for consistency.

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
  // MAIN CONTENT — Stack layout
  // ─────────────────────────────────────────────────────────────────────────
  //
  // Why Stack?
  // The button row must stay FIXED at the bottom even when the user scrolls.
  // Stack lets us layer:
  //   Layer 0 (back): SingleChildScrollView — all the hotel content
  //   Layer 1 (front): Positioned button row pinned to bottom
  //
  // The scrollable content has bottom padding of 120 to ensure the last
  // item is never hidden behind the fixed button row.

  Widget _buildContent(BuildContext context, HotelModel hotel) {
    return Stack(
      children: [
        // ── SCROLLABLE CONTENT ────────────────────────────────────────────
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // iOS elastic overscroll feel
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            120, // Reserve space so content doesn't hide behind bottom buttons
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── BLUE GRADIENT SECTION ─────────────────────────────────
              // Same gradient + rounded top corners as the flight screen.
              // Contains: banner + white card.
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
                      // Blue "Auto Pilot Booking" confirmation banner
                      _buildBanner(),
                      const SizedBox(height: AppSpacing.lg),

                      // White card — contains ALL hotel info
                      _buildHotelCard(hotel),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),

        // ── FIXED BOTTOM BUTTONS ──────────────────────────────────────────
        // Positioned pins this widget relative to the Stack, not the scroll.
        // SafeArea inside ensures it clears the home indicator on iPhones.
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: 24,
          child: SafeArea(
            child: AppButtonRow(
              outlinedText: 'Edit Hotel',
              filledText: 'View Car Rental',
              filledIcon: AppIcons.forward,
              onOutlinedPressed: () {
                // TODO: Navigate to edit hotel screen
              },
              onFilledPressed: () {
                // push() keeps back navigation — user can return Hotel → Car
                context.push('/autopilot/car');
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
  // Identical structure to the flight screen banner — white circle check +
  // title + subtitle. Only the subtitle text changes.
  //
  // Design principle: consistency. A user recognises this as the same
  // confirmation banner they saw on the flight screen → reduces cognitive load.

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          // White circle — "secured" confirmation icon
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
                  'OmVrti.ai has secured hotel for your upcoming journey',
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
  // WIDGET: HOTEL CARD (white card containing all hotel details)
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Structure inside the card (top → bottom):
  //   1. "Stay at New York" header with bed icon
  //   2. Full-width hotel hero image with rounded top corners
  //   3. Hotel name + area + "In Policy" badge + price (side by side)
  //   4. OmVrti Rewards badge (right-aligned)
  //   5. Thin divider
  //   6. Amenity rows (check-in, check-out, parking, breakfast, stars, walk)

  Widget _buildHotelCard(HotelModel hotel) {
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
      // ClipRRect clips the card's children to the rounded corners.
      // Without this, the hotel image would overflow and ignore the card's
      // border radius at the top corners.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. "Stay at New York" header ──────────────────────────────
            _buildStayHeader(hotel.destinationCity),

            // ── 2. Full-width hotel hero image ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: _buildHotelImage(hotel.imageAsset),
            ),

            // ── 3 & 4 & 5 & 6. Hotel info section (with padding) ─────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name + policy badge + price in one row
                  _buildHotelNameAndPrice(hotel),
                  const SizedBox(height: AppSpacing.sm),

                  // Rewards badge — right-aligned
                  _buildRewardsBadge(hotel),
                  const SizedBox(height: AppSpacing.md),

                  // Thin separator between price and amenities
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFEEEEEE),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // All amenity rows
                  _buildAmenitiesSection(hotel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: "Stay at New York" HEADER
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Sits at the very top of the card with a light blue-gray background.
  // [🛏 icon]  Stay at {city}
  //
  // The colored background helps differentiate the header from the white card body.

  Widget _buildStayHeader(String city) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      // Subtle blue tint — same palette as the flight card's accent areas
      color: const Color(0xFFF0F4FF),
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.bed_vector,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Stay at $city',
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
  // WIDGET: HOTEL HERO IMAGE
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Full-width image with a fixed height.
  // BoxFit.cover ensures the image fills the space without distortion —
  // it crops if needed, which is correct behaviour for hero images.
  //
  // The image sits edge-to-edge (no horizontal padding) for a dramatic look.

  Widget _buildHotelImage(String imageAsset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        height: 180,
        child: Image.asset(
          imageAsset,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFE8EAF6),
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.textMuted,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: HOTEL NAME + AREA + POLICY BADGE + PRICE
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Layout: two columns side by side
  //   LEFT col  (Expanded): hotel name → area → subArea  (text wraps)
  //   RIGHT col (shrink):   [In Policy badge] → $275 → "per night"
  //
  // Using Row + Expanded on the left prevents long hotel names from
  // pushing the price off-screen. The price column uses mainAxisSize.min
  // so it only takes as much space as it needs.

  Widget _buildHotelNameAndPrice(HotelModel hotel) {
    const Color policyGreen = AppColors.success;
    const Color policyGreenLight = Color(0xFFE8F5EE);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT: Hotel name + location ───────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel name — bold, primary color (matches design's blue text)
              Text(
                hotel.hotelName,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Area (e.g. "New York Downtown")
              Text(
                hotel.hotelArea,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              // Sub-area (e.g. "Manhattan/WTC Area")
              Text(
                hotel.hotelSubArea,
                style: AppTextStyles.bodyMedium.copyWith(
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
            // "In Policy" pill badge — same as flight screen
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
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
              '\$${hotel.pricePerNight.toStringAsFixed(0)}',
              style: AppTextStyles.price.copyWith(
                color: policyGreen,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                height: 1.0, // Tight line-height so badge and price sit close
              ),
            ),

            // "per night" label
            Text(
              'per night',
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
  // Right-aligned gold/green pill: 🪙 $10 OmVrti Rewards
  // Identical logic to flight screen's _buildRewardsBadge().

  Widget _buildRewardsBadge(HotelModel hotel) {
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
            // Coin SVG icon — same as flight screen
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
                  '\$${hotel.rewardsAmount.toStringAsFixed(0)}',
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
  // WIDGET: AMENITIES SECTION
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Renders all hotel amenities in a vertical list of icon + label rows.
  // Also handles the special cases that aren't in the amenities list:
  //   - Check-in date/time  → treated as a special amenity row
  //   - Check-out date/time → treated as a special amenity row
  //   - Star rating         → "Rated X-Star"
  //   - Walk time           → "X mins walk to downtown"
  //
  // WHY hardcode check-in/out separately instead of putting in amenities list?
  // → Check-in and check-out need BOTH a date (formatted from DateTime) AND
  //   a time string. That's a different data shape from a simple label string.
  //   Putting them in HotelAmenity would force us to store pre-formatted strings
  //   in the model, which is bad practice (model shouldn't format data).

  Widget _buildAmenitiesSection(HotelModel hotel) {
    return Column(
      children: [
        // ── Check-in row (special — uses DateTime + time string) ──────────
        _buildDateAmenityRow(
          iconAsset: AppIcons.calendar, // calendar SVG icon
          label: 'Check in',
          date: Formatters.formatDate(hotel.checkInDate),
          time: hotel.checkInTime,
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Check-out row ─────────────────────────────────────────────────
        _buildDateAmenityRow(
          iconAsset: AppIcons.calendar,
          label: 'Check Out',
          date: Formatters.formatDate(hotel.checkOutDate),
          time: hotel.checkOutTime,
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Dynamic amenity rows from the list ────────────────────────────
        // Using .map() + Column avoids manually listing each amenity.
        // When the API adds more amenities, they automatically appear
        // without any UI code changes — this is "data-driven UI".
        ...hotel.amenities.map(
          (amenity) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildAmenityRow(
              iconAsset: amenity.iconAsset,
              label: amenity.label,
            ),
          ),
        ),

        // ── Star rating row (special — builds label from int) ─────────────
        _buildAmenityRow(
          iconAsset: AppIcons.star, // star SVG icon
          label: 'Rated ${hotel.starRating}-Star',
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Walk time row ─────────────────────────────────────────────────
        _buildAmenityRow(
          iconAsset: AppIcons.walk, // walking person SVG icon
          label: hotel.walkTime,
        ),
      ],
    );
  }

  // ── Single amenity row (icon + label) ────────────────────────────────────
  //
  // Used for: Free Parking, Buffet Breakfast, Star rating, Walk time.
  // Icon is an SVG from AppIcons. Label is a plain string.
  //
  // The SVG color filter applies AppColors.primary so all icons
  // match the app's brand color, regardless of the SVG's original color.

  Widget _buildAmenityRow({
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
            AppColors.accent,
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

  // ── Date amenity row (icon + label + date + time) ─────────────────────────
  //
  // Used ONLY for check-in and check-out, which need to show:
  //   [📅 icon]  Check in  •  Tue, Jun 1, 2026  •  12 PM
  //
  // The bullet (•) separates the label, date, and time visually.
  // Using RichText with multiple TextSpans lets us style parts differently
  // (e.g. date in a slightly different color than the label).

  Widget _buildDateAmenityRow({
    required String iconAsset,
    required String label,
    required String date,
    required String time,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          iconAsset,
          width: 18,
          height: 18,
          colorFilter: const ColorFilter.mode(
            AppColors.accent,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Expanded prevents overflow on small screens
        Expanded(
          child: RichText(
            // RichText lets us mix text styles in a single line.
            // TextSpan is a span of text with its own style.
            text: TextSpan(
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
              children: [
                // "Check in" — slightly bolder label
                TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                // Bullet separator
                TextSpan(
                  text: '  •  ',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                // Formatted date — e.g. "Tue, Jun 1, 2026"
                TextSpan(text: date),
                // Bullet separator
                TextSpan(
                  text: '  •  ',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                // Time — e.g. "12 PM"
                TextSpan(text: time),
              ],
            ),
          ),
        ),
      ],
    );
  }
}