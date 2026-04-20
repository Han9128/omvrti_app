import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            const OmvrtiAppBar(showBack: true),
            Expanded(
              child: tripAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (trip) => flightAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(e.toString())),
                  data: (flight) => _buildContent(context, trip, flight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildContent(BuildContext context, TripModel trip, FlightModel flight) {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(AppSpacing.lg),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const SizedBox(height: AppSpacing.md),
  //         _buildBanner(),
          
  //         const SizedBox(height: AppSpacing.lg),
  //         _buildPricingRow(flight),
  //         const SizedBox(height: AppSpacing.md),
  //         _buildRewardsBadge(flight),
  //         const SizedBox(height: AppSpacing.xxl),
  //         AppButtonRow(
  //           outlinedText: 'Edit Flight',
  //           filledText: 'View Hotel',
  //           filledIcon: AppIcons.forward,
  //           onOutlinedPressed: () {},
  //           onFilledPressed: () {},
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildContent(BuildContext context, TripModel trip, FlightModel flight) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                _buildBanner(),
                const SizedBox(height: 80), // space for overlap
              ],
            ),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildFlightCard(trip, flight),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xxl),

        AppButtonRow(
          outlinedText: 'Edit Flight',
          filledText: 'View Hotel',
          filledIcon: AppIcons.forward,
          onOutlinedPressed: () {},
          onFilledPressed: () {},
        ),
      ],
    ),
  );
}

  // ── Banner ─────────────────────────────────────────────────────────────────

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto Pilot Booking',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'OmVrti.ai has secured flight for your upcoming journey',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Flight Card ────────────────────────────────────────────────────────────

  Widget _buildFlightCard(TripModel trip, FlightModel flight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        children: [
          _buildFlightSection(
            icon: Icons.flight_takeoff_rounded,
            label: 'Departing Flight',
            date: Formatters.formatDate(trip.departDate),
            fromTime: flight.departTime,
            toTime: flight.departArrival,
            fromCode: flight.departAirport,
            toCode: flight.arrivalAirport,
            airline: flight.airline,
            flightNumber: flight.departFlightNumber,
            flightClass: flight.flightClass,
            stops: flight.stops,
            duration: flight.departDuration,
          ),
          const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
          _buildFlightSection(
            icon: Icons.flight_land_rounded,
            label: 'Returning Flight',
            date: Formatters.formatDate(trip.returnDate),
            fromTime: flight.returnTime,
            toTime: flight.returnArrival,
            fromCode: flight.arrivalAirport,
            toCode: flight.departAirport,
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

  Widget _buildFlightSection({
    required IconData icon,
    required String label,
    required String date,
    required String fromTime,
    required String toTime,
    required String fromCode,
    required String toCode,
    required String airline,
    required String flightNumber,
    required String flightClass,
    required String stops,
    required String duration,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: icon + label + date ──────────────────────────────────
          Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$label – $date',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Times row ─────────────────────────────────────────────────────
          Row(
            children: [
              Text(fromTime, style: AppTextStyles.h4),
              Expanded(child: _buildDottedLine()),
              Text(toTime, style: AppTextStyles.h4),
            ],
          ),
          const SizedBox(height: 4),

          // ── Airport codes row ─────────────────────────────────────────────
          Row(
            children: [
              Text(
                fromCode,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                toCode,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Airline info row ──────────────────────────────────────────────
          Row(
            children: [
              const Text('🇺🇸', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                airline,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                flightNumber,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Avg emissions',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Details row ───────────────────────────────────────────────────
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

  Widget _buildDottedLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dotWidth = 4.0;
          const gap = 4.0;
          final count = (constraints.maxWidth / (dotWidth + gap)).floor();
          return Row(
            children: List.generate(count, (_) => Container(
              width: dotWidth,
              height: 1.5,
              margin: const EdgeInsets.only(right: gap),
              color: AppColors.textMuted,
            )),
          );
        },
      ),
    );
  }

  // ── Pricing ────────────────────────────────────────────────────────────────

  Widget _buildPricingRow(FlightModel flight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // "In Policy" badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'In Policy',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Price
            Text(
              '\$${flight.price.toStringAsFixed(0)}',
              style: AppTextStyles.h1.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w800,
                fontSize: 36,
              ),
            ),

            // "round trip" label
            Text(
              'round trip',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Rewards Badge ──────────────────────────────────────────────────────────

  Widget _buildRewardsBadge(FlightModel flight) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD700), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪙', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              '\$${flight.rewardsAmount.toStringAsFixed(0)} OmVrti Rewards',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF856404),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
