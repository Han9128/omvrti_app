import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/utils/formatters.dart';
import 'package:omvrti_app/core/widgets/app_button.dart';
import 'package:omvrti_app/core/widgets/app_button_row.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/autopilot/model/trip_model.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/autopilot_viewmodel.dart';

class AutopilotAlertScreen extends ConsumerWidget {
  const AutopilotAlertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripProvider);

    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        child: Column(
          children: [
            const OmvrtiAppBar(),
            Expanded(
              child: tripAsync.when(
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
                data: (trip) => _buildContent(context, trip),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TripModel trip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          _buildAlertBanner(),
          const SizedBox(height: AppSpacing.lg),
          _buildInfoCard(trip),
          const SizedBox(height: AppSpacing.lg),
          _buildRouteCard(trip),
          const SizedBox(height: AppSpacing.lg),
          _buildServicesCard(trip),
          const SizedBox(height: AppSpacing.lg),
          _buildTravelerCard(trip),
          const SizedBox(height: AppSpacing.xxl),
          // const SizedBox(height: AppSpacing.xxxl),
          // the two button row at bottom
          AppButtonRow(
            outlinedText: 'Edit Trip',
            filledText: 'View Flight',
            filledIcon: AppIcons.forward,
            onOutlinedPressed: () {
              // TODO: navigate to edit trip
            },
            onFilledPressed: () {
              // context.go() is go_router's navigation method
              // It replaces the current screen with the new one
              //
              // context.go()    → replace current screen (no back button)
              // context.push()  → push on top (back button returns here)
              //
              // For this flow we use push() because:
              // User should be able to go back from Flight → Alert
              context.push('/autopilot/flight');
            },
          ),
        ],
      ),
    );
  }

  // ── 1. Alert Banner ────────────────────────────────────────────────────────
  // Blue banner with robot icon in a white circle, bold title, date below

  Widget _buildAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        // Brighter blue matching the design — distinct from the navy home card
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Row(
        children: [
          Image.asset(
            AppImages.autoPilotRobot,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AutoPilot Trip Alert',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Mon, Mar 2, 2026',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. Info Card ───────────────────────────────────────────────────────────
  // Single white card with 3 sections divided by dividers:
  // Purpose | Estimated Spend | Meeting Schedule + Location

  Widget _buildInfoCard(TripModel trip) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        children: [
          // ── Section 1: Purpose ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Briefcase icon — matches design
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Image.asset(
                    AppImages.meetingBag,
                    errorBuilder: (_, __, ___) => const Icon(
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
                      const SizedBox(height: 2),
                      Text(
                        trip.purpose,
                        style: AppTextStyles.h4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),

          // ── Section 2: Estimated Spend ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppIcons.dollar,
                  width: 44,
                  height: 44,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Spend',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${trip.estimatedBudget.toStringAsFixed(0)}',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Section 3: Meeting Schedule + Location ─────────────────────
          // Only show if meeting data is available
          if (trip.firstMeeting != null || trip.meetingLocation != null) ...[
            const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blue calendar icon in a circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meeting Schedule',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // First meeting time
                        if (trip.firstMeeting != null)
                          Text(
                            trip.firstMeeting!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),

                        // Last meeting time
                        if (trip.lastMeeting != null)
                          Text(
                            trip.lastMeeting!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),

                        // Meeting location — shown as a sub-section below
                        if (trip.meetingLocation != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Meeting Location',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trip.meetingLocation!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── 3. Route Card ──────────────────────────────────────────────────────────
  // Origin / Destination cities, then "Depart Date" / "Return Date" labels
  // with bold dates AND times below each, then trip duration

  Widget _buildRouteCard(TripModel trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        children: [
          // ── Cities row ─────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.originCity, style: AppTextStyles.h4),
                    const SizedBox(height: 2),
                    Text(
                      trip.originState,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Flight return icon
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    AppImages.flightReturn,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.swap_horiz,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trip.destCity,
                      style: AppTextStyles.h4,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.destState,
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

          // const SizedBox(height: AppSpacing.md),
          // const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
          const Divider(),
          // const SizedBox(height: AppSpacing.md),R

          // ── Dates row — "Depart Date" / "Return Date" labels ───────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label: "Depart Date" (matching design exactly)
                    Text(
                      'Depart Date',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatDate(trip.departDate),
                      style: AppTextStyles.h4,
                    ),
                    // Time range below the date
                    if (trip.departTime != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        trip.departTime!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Return Date',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatDate(trip.returnDate),
                      style: AppTextStyles.h4,
                      textAlign: TextAlign.right,
                    ),
                    if (trip.returnTime != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        trip.returnTime!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Trip duration — centered, blue text matching design
          Text(
            'Trip Duration : ${trip.tripDuration} Days',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Services Card ───────────────────────────────────────────────────────
  // Accommodation + Car Rental in a single card with divider between them
  // Each row has a blue circular icon, a gray label, and black description

  Widget _buildServicesCard(TripModel trip) {
    final hasAccommodation = trip.accommodationNote != null;
    final hasCar = trip.carRentalNote != null;

    // Don't render the card if neither service is present
    if (!hasAccommodation && !hasCar) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        children: [
          if (hasAccommodation)
            _buildServiceRow(
              icon: Icons.hotel_outlined,
              label: 'Accommodation',
              description: trip.accommodationNote!,
            ),

          if (hasAccommodation && hasCar)
            const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),

          if (hasCar)
            _buildServiceRow(
              icon: Icons.directions_car_outlined,
              label: 'Car Rental',
              description: trip.carRentalNote!,
            ),
        ],
      ),
    );
  }

  Widget _buildServiceRow({
    required IconData icon,
    required String label,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // Blue circular icon — matches the design
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F1FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4A90E2), size: 22),
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
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

  // ── 5. Traveler Card ───────────────────────────────────────────────────────

  Widget _buildTravelerCard(TripModel trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Travelers',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              SvgPicture.asset(
                AppIcons.profileIcon,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(trip.travelerName, style: AppTextStyles.h4),
            ],
          ),
        ],
      ),
    );
  }

  // ── 6. Button Row ──────────────────────────────────────────────────────────
  // "Edit Trip" outlined with red border | "View Flight >" filled red

//   Widget _buildButtonRow(BuildContext context) {
//     return Row(
//       children: [
//         // Edit Trip — outlined button with red border
//         Expanded(
//           child: AppOutlinedButton(
//             text: 'Edit Trip',
//             borderColor: AppColors.accent,
//             onPressed: () {
//               // TODO: Navigate to edit trip screen
//             },
//           ),
//         ),
//         const SizedBox(width: AppSpacing.lg),

//         // View Flight — filled red with forward chevron
//         Expanded(
//           child: AppFilledButton(
//             text: 'View Flight',
//             icon: AppIcons.forward,
//             onPressed: () => context.push('/autopilot/flight'),
//           ),
//         ),
//       ],
//     );
//   }
// }

}