import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:omvrti_app/core/utils/formatters.dart';
import 'package:omvrti_app/core/widgets/app_button_row.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/autopilot_viewmodel.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../model/trip_model.dart';

class AutopilotAlertScreen extends ConsumerWidget {
  const AutopilotAlertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TripModel> tripAsync = ref.watch(tripProvider);

    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        child: Column(
          children: [
            const OmvrtiAppBar(),
            Expanded(
              child: tripAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(AppSpacing.lg),
                    child: Text(
                      error.toString(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (trip) => _buildContent(context, trip, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TripModel trip, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          _buildAlertBanner(),
          const SizedBox(height: AppSpacing.xl),
          _buildPurposeCard(trip),
          const SizedBox(height: AppSpacing.xl),
          _buildRouteCard(trip),
          const SizedBox(height: AppSpacing.xl),

          // NEW: Services card shown only when trip has accommodation/car data
          if (trip.accommodationNote != null || trip.carRentalNote != null) ...[
            _buildServicesCard(trip),
            const SizedBox(height: AppSpacing.xl),
          ],

          _buildTravelerCard(trip),
          const SizedBox(height: AppSpacing.xxxl),
          AppButtonRow(
            outlinedText: 'Edit Trip',
            filledText: 'View Flight',
            filledIcon: AppIcons.forward,
            onOutlinedPressed: () {
              // TODO: navigate to edit trip
            },
            onFilledPressed: () {
              context.push('/autopilot/flight');
            },
          ),
        ],
      ),
    );
  }

  // UNCHANGED — alert banner exactly as original
  Widget _buildAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Image.asset(
              AppImages.autoPilotRobot,
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Autopilot Trip Alert',
                style: AppTextStyles.h1.copyWith(color: AppColors.surface),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Mon, Mar 2, 2026',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UPDATED — added Meeting Schedule section below Estimated Spend
  Widget _buildPurposeCard(TripModel trip) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
      ),
      child: Column(
        children: [

          // Purpose row — unchanged
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(AppImages.meetingBag),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purpose',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          trip.purpose,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '●',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          trip.company,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(),

          // Estimated Spend row — label updated from "Estimated Budget"
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: SvgPicture.asset(AppIcons.dollar),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Spend',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${trip.estimatedBudget.toStringAsFixed(0)}',
                      style: AppTextStyles.price.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // NEW: Meeting Schedule section — only shown when data exists
          if (trip.firstMeeting != null ||
              trip.lastMeeting != null ||
              trip.meetingLocation != null) ...[
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blue circle calendar icon matching design
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3EEFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF4A90E2),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meeting Schedule',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (trip.firstMeeting != null)
                        Text(
                          trip.firstMeeting!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      if (trip.lastMeeting != null)
                        Text(
                          trip.lastMeeting!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      // Meeting Location sub-label + address
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
          ],
        ],
      ),
    );
  }

  // UPDATED — "Depart Date"/"Return Date" labels + times below dates + blue duration
  Widget _buildRouteCard(TripModel trip) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
      ),
      child: Column(
        children: [
          // Cities row — unchanged (removed airport lines to match design)
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
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(AppImages.flightReturn),
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

          const Divider(),

          // Dates row — labels updated + time ranges added below dates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT: Depart Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Depart Date', style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatDate(trip.departDate),
                    style: AppTextStyles.h4,
                  ),
                  // Time range — only shown when available
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

              // RIGHT: Return Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Return Date', style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatDate(trip.returnDate),
                    style: AppTextStyles.h4,
                  ),
                  // Time range — only shown when available
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
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Trip Duration — now blue to match design
          Text(
            'Trip Duration : ${trip.tripDuration} Days',
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF4A90E2),
            ),
          ),
        ],
      ),
    );
  }

  // NEW — Services card with Accommodation + Car Rental rows
  Widget _buildServicesCard(TripModel trip) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
      ),
      child: Column(
        children: [
          if (trip.accommodationNote != null)
            _buildServiceRow(
              icon: AppIcons.bed,
              label: 'Accommodation',
              description: trip.accommodationNote!,
            ),
          if (trip.accommodationNote != null && trip.carRentalNote != null)
            const Divider(height: 1),
          if (trip.carRentalNote != null)
            _buildServiceRow(
              icon: AppIcons.car_rental,
              label: 'Car Rental',
              description: trip.carRentalNote!,
            ),
        ],
      ),
    );
  }

  // Reusable row for each service item
  Widget _buildServiceRow({
    required String icon,
    required String label,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Blue circle icon matching design
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(icon, width: 24, height: 24, colorFilter: const ColorFilter.mode(
    AppColors.textWhite,
    BlendMode.srcIn,
  ),),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
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

  // UNCHANGED — traveler card exactly as original
  Widget _buildTravelerCard(TripModel trip) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Travelers',
            style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: SvgPicture.asset(AppIcons.profileIcon),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(trip.travelerName, style: AppTextStyles.h4),
            ],
          ),
        ],
      ),
    );
  }
}