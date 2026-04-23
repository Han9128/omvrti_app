import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/features/home/model/home_state.dart';
import 'package:omvrti_app/features/home/viewmodel/home_viewmodel.dart';

// AddMeetingBottomSheet shows two options:
//   1. Import from Google Calendar → triggers OAuth + fetch flow
//   2. Add manually → dismisses sheet → navigates to ManualTripScreen
//
// The calendar flow auto-closes the sheet when trip is fetched.
// The manual flow closes the sheet first then pushes the form screen.

class AddMeetingBottomSheet extends ConsumerWidget {
  const AddMeetingBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surface,
      builder: (_) => const AddMeetingBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    // Auto-close when calendar trip is fetched — HomeScreen handles navigation
    ref.listen<HomeState>(homeProvider, (previous, next) {
      if (next.isCalendarConnected && context.mounted) {
        Navigator.of(context).pop();
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title + subtitle
            Text(
              'Add a Trip',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'How would you like to add your trip?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // No-events message — friendly prompt to add manually
            if (state.isNoEvents) ...[
              _buildNoEventsMessage(context),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Error banner for genuine failures (auth, network, etc.)
            if (state.hasError && state.errorMessage != null) ...[
              _buildErrorBanner(state.errorMessage!),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Status message during calendar loading
            if (state.isCalendarLoading) ...[
              _buildStatusMessage(state),
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── Option 1: Import from Google Calendar ────────────────
            _buildOptionTile(
              icon: Icons.calendar_month_outlined,
              iconBgColor: const Color(0xFFEEF2FF),
              iconColor: const Color(0xFF1A3C8F),
              title: 'Import from Google Calendar',
              subtitle: 'Connect and sync your travel events automatically',
              isLoading: false,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/calendar');
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Option 2: Add manually ───────────────────────────────
            // Closes the bottom sheet first, then pushes the form screen.
            // We close first so the sheet doesn't linger behind the form.
            _buildOptionTile(
              icon: Icons.edit_outlined,
              iconBgColor: const Color(0xFFFFF0EE),
              iconColor: AppColors.accent,
              title: 'Add manually',
              subtitle: 'Enter your trip details yourself',
              isLoading: false,
              onTap: () {
                // Close the bottom sheet
                Navigator.of(context).pop();
                // Navigate to the manual trip entry form
                // Using push so user can come back to Home with back arrow
                context.push('/autopilot/manual-trip');
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Cancel link
            Center(
              child: GestureDetector(
                onTap: state.isCalendarLoading
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: state.isCalendarLoading
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textMuted.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading && icon == Icons.calendar_month_outlined
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: iconColor,
                      ),
                    )
                  : Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage(HomeState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            state.isConnecting
                ? 'Opening Google sign-in...'
                : 'Scanning your calendar for trips...',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEventsMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF9B6D00),
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'No events found in your calendar',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF9B6D00),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your Google Calendar doesn\'t have any upcoming travel events. You can add your trip details manually instead.',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF9B6D00),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              context.push('/autopilot/manual-trip');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Add trip manually',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}