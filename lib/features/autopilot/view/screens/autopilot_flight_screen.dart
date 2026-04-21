// ─────────────────────────────────────────────────────────────────────────────
// AUTOPILOT FLIGHT SCREEN
// ─────────────────────────────────────────────────────────────────────────────
//
// STEP 2 of the AutoPilot booking flow:
//   Alert → [Flight] → Hotel → Car → Summary
//
// SCREEN LAYOUT (top → bottom):
//   1. OmvrtiAppBar (showBack: true — back arrow on left)
//   2. Blue "Auto Pilot Booking" confirmation banner
//   3. Light-blue flight card:
//        • Departing Flight section
//        • thin divider
//        • Returning Flight section
//   4. "In Policy" badge + "$515" large green price + "round trip" (right-aligned, OUTSIDE card)
//   5. Gold "🪙 $10 OmVrti Rewards" pill badge (right-aligned)
//   6. "Edit Flight" outlined | "View Hotel >" filled button row
//
// DATA:
//   • tripProvider   → FutureProvider<TripModel>   (departDate, returnDate)
//   • flightProvider → FutureProvider<FlightModel>  (times, airline, price, etc.)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/utils/formatters.dart';
import 'package:omvrti_app/core/widgets/app_button_row.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/autopilot/model/flight_model.dart';
import 'package:omvrti_app/features/autopilot/model/trip_model.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/autopilot_viewmodel.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/flight_viewmodel.dart';




class AutopilotFlightScreen extends ConsumerWidget {
  const AutopilotFlightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripProvider);
    final flightAsync = ref.watch(flightProvider);

    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Back arrow — tapping returns to the Alert Screen
            const OmvrtiAppBar(showBack: true),

            Expanded(
              // Nested .when():
              // We need BOTH tripAsync AND flightAsync to have data before
              // we can render the screen. If either is loading we show a
              // spinner. If either errors we show the error message.
              //
              // Why nested and not a separate combinedProvider?
              // Keeping them separate makes each provider independently
              // reusable by other screens (e.g. Summary screen also needs
              // flightProvider). Combining them would create tight coupling.
              child: tripAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _buildErrorState(e.toString()),
                data: (trip) => flightAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _buildErrorState(e.toString()),
                  data: (flight) => _buildContent(context, trip, flight),
                ),
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
  // Extracted to avoid duplicating the same widget in both .when() error
  // branches above. Shows the error message centered with an icon.

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
  // MAIN CONTENT
  // ─────────────────────────────────────────────────────────────────────────
  // ScrollView wrapping all sections. BouncingScrollPhysics gives the iOS
  // elastic overscroll effect that feels natural on mobile.

  // Widget _buildContent(
  //   BuildContext context,
  //   TripModel trip,
  //   FlightModel flight,
  // ) {
  //   return SingleChildScrollView(
  //     physics: const BouncingScrollPhysics(),
  //     padding: const EdgeInsets.fromLTRB(
  //       AppSpacing.lg,
  //       AppSpacing.sm,
  //       AppSpacing.lg,
  //       AppSpacing.xxxl,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // ── 1. Confirmation banner ─────────────────────────────────────
  //         _buildBanner(),
  //         const SizedBox(height: AppSpacing.lg),

  //         // ── 2. Light-blue flight card (depart + return combined) ───────
  //         _buildCombinedFlightCard(trip, flight),
  //         const SizedBox(height: AppSpacing.lg),

  //         // ── 3. Price block — OUTSIDE the card, right-aligned ──────────
  //         _buildPriceBlock(flight),
  //         const SizedBox(height: AppSpacing.sm),

  //         // ── 4. Rewards badge — right-aligned ──────────────────────────
  //         _buildRewardsBadge(flight),
  //         const SizedBox(height: AppSpacing.xxl),

  //         // ── 5. Edit Flight | View Hotel buttons ────────────────────────
  //         AppButtonRow(
  //           outlinedText: 'Edit Flight',
  //           filledText: 'View Hotel',
  //           filledIcon: AppIcons.forward,
  //           onOutlinedPressed: () {
  //             // TODO: Navigate to edit flight screen
  //           },
  //           onFilledPressed: () {
  //             // Push keeps back navigation — user can return from Hotel → Flight
  //             context.push('/autopilot/hotel');
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildContent(
    BuildContext context,
    TripModel trip,
    FlightModel flight,
  ) {
    return Stack(
      children: [
        // ─────────────────────────────────────────────
        // SCROLLABLE CONTENT
        // ─────────────────────────────────────────────
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            120, // 👈 IMPORTANT: space for button
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // 🔵 BLUE SECTION
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

                      Container(
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
                        child: Column(
                          children: [
                            _buildCombinedFlightCard(trip, flight),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.lg,
                              ),
                              child: Column(
                                children: [
                                  _buildPriceBlock(flight),
                                  const SizedBox(height: AppSpacing.sm),
                                  _buildRewardsBadge(flight),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),

        // ─────────────────────────────────────────────
        // FIXED BOTTOM BUTTON
        // ─────────────────────────────────────────────
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: 24,
          child: SafeArea(
            child: AppButtonRow(
              outlinedText: 'Edit Flight',
              filledText: 'View Hotel',
              filledIcon: AppIcons.forward,
              onOutlinedPressed: () {},
              onFilledPressed: () {
                context.push('/autopilot/hotel');
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
  // Blue pill/card with:
  //   Left:  White circle with blue checkmark (44×44)
  //   Right: Bold title + subtitle text

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        // color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Row(
        children: [
          // White circle — "confirmed" check icon
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
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    // fontWeight: FontWeight.w800,
                    // fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'OmVrti.ai has secured  flight for your upcoming journey',
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
  // WIDGET: COMBINED FLIGHT CARD
  // ══════════════════════════════════════════════════════════════════════════
  //
  // ONE card with a very light blue-gray background (#F5F7FF).
  // Contains departing + returning flight sections divided by a thin line.
  //
  // Key design insight: price + rewards are BELOW this card,
  // not inside it — keep them separate.

  Widget _buildCombinedFlightCard(TripModel trip, FlightModel flight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Slightly off-white with a cool blue tint — as seen in the screenshot
        // color: const Color(0xFFF4F6FF),
        // borderRadius: BorderRadius.circular(AppSpacing.xl),
        // border: Border.all(
        //   color: const Color(0xFFE4E9FF),
        //   width: 1,
        // ),
      ),
      child: Column(
        children: [
          // Departing flight section (takeoff icon)
          _buildFlightSection(
            icon: AppIcons.flight_takeoff,
            label: 'Departing Flight',
            date: Formatters.formatDate(trip.departDate),
            departureTime: flight.departTime,
            arrivalTime: flight.departArrival,
            departureCode: flight.departAirport,
            arrivalCode: flight.arrivalAirport,
            airline: flight.airline,
            flightNumber: flight.departFlightNumber,
            flightClass: flight.flightClass,
            stops: flight.stops,
            duration: flight.departDuration,
          ),

          // Thin divider between sections
          // Using a custom color that blends with the card background
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFDDE3FF),
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),

          // Returning flight section (landing icon)
          // NOTE: airports are SWAPPED for return — JFK departs, SFO arrives
          _buildFlightSection(
            icon: AppIcons.flight_landing,
            label: 'Returning Flight',
            date: Formatters.formatDate(trip.returnDate),
            departureTime: flight.returnTime,
            arrivalTime: flight.returnArrival,
            departureCode: flight.arrivalAirport, // JFK on return
            arrivalCode: flight.departAirport, // SFO on return
            airline: flight.airline,
            flightNumber: flight.returnFlightNumber,
            flightClass: flight.flightClass,
            stops: flight.stops,
            duration: flight.returnDuration,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: SINGLE FLIGHT SECTION (reusable for depart and return)
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Layout (pixel-matched to design):
  //
  //   ✈  Departing Flight – Mon, Jun 1, 2026
  //
  //   8:30 AM  ────────────  4:55 PM
  //   SFO                      JFK
  //
  //   🇺🇸 United  UA 435  [Avg emissions]
  //   Economy • Nonstop • 5h 25m
  //
  // Parameters are all required — each one maps to a visible UI element.
  // Named parameters make the call sites at the bottom very readable.

  Widget _buildFlightSection({
    required String icon, // flight takeoff or landing icon
    required String label, // "Departing Flight" or "Returning Flight"
    required String date, // formatted date string
    required String departureTime, // "8:30 AM"
    required String arrivalTime, // "4:55 PM"
    required String departureCode, // "SFO"
    required String arrivalCode, // "JFK"
    required String airline, // "United"
    required String flightNumber, // "UA 435"
    required String flightClass, // "Economy"
    required String stops, // "Nonstop"
    required String duration, // "5h 25m"
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ROW 1: Icon + "Label – Date" ───────────────────────────────
          // e.g.  ✈  Departing Flight – Mon, Jun 1, 2026
          Row(
            children: [
              // Icon(icon, color: AppColors.textPrimary, size: 19),
              SvgPicture.asset(
                icon, // 👈 your svg path
                width: 19,
                height: 19,
                // colorFilter: ColorFilter.mode(
                //   AppColors.textPrimary,
                //   BlendMode.srcIn,
                // ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '$label – $date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── ROW 2: Times with short solid connector line ────────────────
          // Design: "8:30 AM  ─────  4:55 PM"
          // The line is short and centered, NOT full-width dotted.
          // We use a fixed-width centered Container for the line.
          Row(
            children: [
              // Departure time — bold
              Text(
                departureTime,
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),

              // The connector line lives inside Expanded so it fills the
              // gap between the two times. It's centered via Center widget.
              Expanded(child: _buildConnectorLine()),

              // Arrival time — bold
              Text(
                arrivalTime,
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          // ── ROW 3: Airport codes ────────────────────────────────────────
          // Sits directly under the times. Left = departure, Right = arrival.
          // Spacer() pushes the right code to align with the arrival time.
          Row(
            children: [
              Text(
                departureCode,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                arrivalCode,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── ROW 4: Airline info row ─────────────────────────────────────
          // 🇺🇸 United  UA 435  [Avg emissions pill]
          
          Row(
            children: [
              Image.asset(
                AppImages.united_logo,
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 5),

              Flexible(
                child: Text(
                  airline,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 5),

              Flexible(
                child: Text(
                  flightNumber,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              _buildEmissionsPill(),
            ],
          ),
          const SizedBox(height: 5),

          // ── ROW 5: Flight details ───────────────────────────────────────
          // "Economy • Nonstop • 5h 25m"
          // Three pieces of flight info separated by bullet points (•)
          Text(
            '$flightClass  •  $stops  •  $duration',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Connector Line ─────────────────────────────────────────────────────────
  // Short solid horizontal line between departure and arrival times.
  //
  // Design observation: This is NOT a full-width line — it's a short
  // fixed-width line centered in the available space.
  // Using Center + Container gives us exactly that.

  Widget _buildConnectorLine() {
    return Center(
      child: Container(
        // ~60px wide matches the design's short connector line
        width: 60,
        height: 1.5,
        color: AppColors.textMuted,
      ),
    );
  }

  // ── Emissions Pill ─────────────────────────────────────────────────────────
  // Small gray rounded pill badge: "Avg emissions"
  // Extracted to its own method since it's used twice (depart + return).

  Widget _buildEmissionsPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        // Slightly darker than card bg to stand out subtly
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Avg emissions',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: PRICE BLOCK
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Sits BELOW the flight card, right-aligned.
  // Three stacked elements:
  //   [✓ In Policy]  ← green pill
  //   $515           ← large bold green price
  //   round trip     ← small gray label
  //
  // The "In Policy" badge is a corporate travel concept — it tells the
  // employee their booking is within their approved travel budget/policy.

  Widget _buildPriceBlock(FlightModel flight) {
    // Green color constants — using a specific dark green for accessibility
    // The design uses a rich green, not the app's default success green
    const Color policyGreen = AppColors.success;
    const Color policyGreenLight = Color(0xFFE8F5EE);

    return Align(
      // Aligns the entire price block to the right edge
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // "In Policy" badge
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
          // Very small gap between badge and price — matches design
          const SizedBox(height: 2),

          // Large price — the dominant visual element in this block
          Text(
            '\$${flight.price.toStringAsFixed(0)}',
            style: AppTextStyles.price.copyWith(
              color: policyGreen,
              // Large font size to match the design's prominent price display
              fontSize: 42,
              fontWeight: FontWeight.w800,
              height: 1.0, // tight line height so it doesn't add too much space
            ),
          ),

          // "round trip" label — small, secondary
          Text(
            'round trip',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: REWARDS BADGE
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Gold/yellow pill badge: 🪙 $10 OmVrti Rewards
  // Right-aligned, sits just below the price block.
  //
  // Design note: The badge has a gold border and warm yellow fill.
  // The text color is a dark amber to ensure readability on the light background.

  Widget _buildRewardsBadge(FlightModel flight) {
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
          color: policyGreenLight, // warm light yellow background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: policyGreen, // gold border
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coin emoji — the "reward" symbol across the whole app
            SvgPicture.asset(
  AppIcons.omvrti_reward, // 👈 your file
  width: 8,
  height: 28,
),
            const SizedBox(width: 5),

            // Amount + brand name in dark amber
            Row(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(
      '\$${flight.rewardsAmount.toStringAsFixed(0)}',
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
}
