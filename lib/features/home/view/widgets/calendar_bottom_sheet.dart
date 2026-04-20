import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/app_button.dart';
import 'package:omvrti_app/features/home/model/home_state.dart';
import 'package:omvrti_app/features/home/viewmodel/home_viewmodel.dart';

// CalendarBottomSheet is shown when the user taps "Import from Google Calendar"
// on the Home Screen.
//
// It explains what access we need and why, then lets the user confirm
// before we launch the OAuth flow. This consent step builds user trust —
// users are more comfortable granting calendar access when they understand
// exactly what will be read and why.
//
// Uses ConsumerStatefulWidget because it watches homeProvider to:
//   - Show a loading spinner during the OAuth + fetch phases
//   - Show an error message if connection fails
//   - Auto-close when trip is successfully fetched

class CalendarBottomSheet extends ConsumerWidget {
  const CalendarBottomSheet({super.key});

  // showAsBottomSheet() is a static helper that makes it easy to display
  // this sheet from anywhere in the app without repeating showModalBottomSheet code.
  //
  // Usage:  CalendarBottomSheet.showAsBottomSheet(context);
  static Future<void> showAsBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,

      // isDismissible: true → user can tap outside to dismiss
      isDismissible: true,

      // enableDrag: true → user can swipe down to dismiss
      enableDrag: true,

      // isScrollControlled: true → sheet can take more than 50% of screen height
      // Without this, a sheet with many items gets clipped
      isScrollControlled: true,

      // Shape gives the sheet the standard rounded top corners
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      backgroundColor: AppColors.surface,

      builder: (_) => const CalendarBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    // When trip is successfully fetched, close the bottom sheet.
    // The HomeScreen listener will then handle navigation to Alert Screen.
    ref.listen<HomeState>(homeProvider, (previous, next) {
      if (next.isCalendarConnected && context.mounted) {
        // Pop the bottom sheet — HomeScreen handles navigation
        Navigator.of(context).pop();
      }
    });

    return Padding(
      // viewInsets.bottom accounts for the keyboard height if it's visible
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
            // ── Drag handle ───────────────────────────────────────────────
            // Standard bottom sheet drag indicator — signals the sheet
            // can be swiped down to dismiss
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

            // ── Header row ────────────────────────────────────────────────
            Row(
              children: [
                // Google Calendar icon tile
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF1A3C8F),
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect Google Calendar',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Find and import your travel events',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Permission explanation ────────────────────────────────────
            // These three items explain exactly what we access and why.
            // Being transparent here increases trust significantly.
            _buildPermissionItem(
              icon: Icons.event_outlined,
              iconColor: AppColors.primary,
              title: 'Read your calendar events',
              subtitle: 'We look for upcoming travel events only',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPermissionItem(
              icon: Icons.flight_outlined,
              iconColor: AppColors.accent,
              title: 'Detect trip details automatically',
              subtitle: 'Dates, destination and purpose from your events',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPermissionItem(
              icon: Icons.lock_outline_rounded,
              iconColor: AppColors.success,
              title: 'Your data stays private',
              subtitle: 'We never store or share your calendar data',
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Error banner ──────────────────────────────────────────────
            if (state.hasError && state.errorMessage != null) ...[
              _buildErrorBanner(context, ref, state.errorMessage!),
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── Status message during loading ─────────────────────────────
            if (state.isCalendarLoading) ...[
              _buildStatusMessage(state),
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── Connect button ────────────────────────────────────────────
            AppFilledButton(
              text: state.hasError ? 'Try Again' : 'Connect Google Calendar',
              isLoading: state.isCalendarLoading,
              onPressed: state.isCalendarLoading
                  ? null
                  : () {
                      // Reset error state if user is retrying
                      if (state.hasError) {
                        ref.read(homeProvider.notifier).resetCalendarError();
                      }
                      // Trigger the full OAuth + fetch flow
                      ref
                          .read(homeProvider.notifier)
                          .connectAndFetchCalendar();
                    },
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Maybe Later link ──────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: state.isCalendarLoading
                    ? null // prevent dismiss during active operation
                    : () => Navigator.of(context).pop(),
                child: Text(
                  'Maybe Later',
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

  // ── Builders ───────────────────────────────────────────────────────────────

  Widget _buildPermissionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colored icon in a soft pill
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Status message shown during the two loading phases.
  // Changes text based on which phase is currently running
  // so the user knows what's happening.
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
          // Small spinning indicator
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
            // Different message for each loading phase
            state.isConnecting
                ? 'Opening Google sign-in...'
                : 'Scanning your calendar for trips...',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(
    BuildContext context,
    WidgetRef ref,
    String message,
  ) {
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