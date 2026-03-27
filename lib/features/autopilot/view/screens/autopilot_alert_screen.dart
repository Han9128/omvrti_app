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

// ConsumerWidget vs ConsumerStatefulWidget
//
// Use ConsumerWidget when the UI only depends on provider state
// and does not require any local state or lifecycle methods.
//
// Use ConsumerStatefulWidget when the UI needs local state such as
// TextEditingController, animations, form handling, or lifecycle methods
// like initState and dispose.
//
// In this screen, ConsumerStatefulWidget is used because we handle
// form inputs and controllers which require proper lifecycle management.

class AutopilotAlertScreen extends ConsumerWidget {
  const AutopilotAlertScreen({super.key});

  @override
  // In ConsumerStatefulWidget, ref is a class property we dont need to pass in build
  // In ConsumerWidget, ref is passed directly into build
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TripModel> tripAsync = ref.watch(tripProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: const OmvrtiAppBar(),
      // safearea gives auto padding to prevent any overflow and items get cut
      body: SafeArea(
        child: Column(
          children: [
            // OmvrtiAppBar(),
            // expanded makes this to take reamining space perfectly without overflowing
            Expanded(
              // handle three states of data getting from view_model file
              child: tripAsync.when(
                // if loading show loading indicator
                loading: () => const Center(child: CircularProgressIndicator()),

                // if error show error message
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

                // when data arrives show the screen content
                data: (trip) => _buildContent(context, trip, ref),
              ),
              // child: _buildContent(),
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
          _buildTravelerCard(trip),
          const SizedBox(height: AppSpacing.xxxl),
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
          // const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  // the blue trip alert banner
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
            // padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              // color: Colors.white.withAlpha(20),
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

  // the purpose card
  Widget _buildPurposeCard(TripModel trip) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
      ),

      // content of purpose card
      child: Column(
        children: [
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
                      'Estimated Budget',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),

                    Text(
                      '\$ ${trip.estimatedBudget}',
                      style: AppTextStyles.price.copyWith(
                        color: AppColors.success,
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

  // Route Card

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // origin information
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
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      trip.originAirport,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // flight depart and return icon
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(AppImages.flightReturn),
                ),
              ),

              // destination information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  // textDirection: TextDirection.rtl,
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
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      trip.destAirport,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Depart', style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatDate(trip.departDate),
                    style: AppTextStyles.h4,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Return', style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatDate(trip.returnDate),
                    style: AppTextStyles.h4,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            'Trip Duration : ${trip.tripDuration} Days',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

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
