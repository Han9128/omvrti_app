import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/calendar/model/sub_calendar_model.dart';
import 'package:omvrti_app/features/calendar/viewmodel/calendar_viewmodel.dart';

class CalendarSyncSettingsScreen extends ConsumerStatefulWidget {
  const CalendarSyncSettingsScreen({super.key});

  @override
  ConsumerState<CalendarSyncSettingsScreen> createState() =>
      _CalendarSyncSettingsScreenState();
}

class _CalendarSyncSettingsScreenState
    extends ConsumerState<CalendarSyncSettingsScreen> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(googleCalendarConnectionProvider);
    final email = connectionState.connectedEmail ?? 'Google Account';
    final calendarAsync = ref.watch(subCalendarListProvider);

    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const OmvrtiAppBar(showBack: true),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // ── LINKED IDENTITIES header ─────────────────────────
                    Text(
                      'LINKED IDENTITIES',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A2B5E),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Currently active synchronization feeds',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Google account card ──────────────────────────────
                    _buildAccountCard(context, email, calendarAsync),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Pro tip banner ───────────────────────────────────
                    _buildProTipBanner(),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Save Changes button ──────────────────────────────
                    _buildSaveButton(context, calendarAsync),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Account card with collapsible calendar list ────────────────────────────

  Widget _buildAccountCard(
    BuildContext context,
    String email,
    AsyncValue<List<SubCalendarModel>> calendarAsync,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                // Calendar icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFFE85C2A),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Active + Google label
                Row(
                  children: [
                    const Icon(Icons.check, color: AppColors.success, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      'ACTIVE',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      '  ·  ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      'GOOGLE',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Disconnect icon
                GestureDetector(
                  onTap: () => _confirmDisconnect(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.link_off_rounded,
                      color: Color(0xFFE85C2A),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Expand / collapse chevron
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Collapsible calendar list ──────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildCalendarList(calendarAsync),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarList(AsyncValue<List<SubCalendarModel>> calendarAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                'AVAILABLE CALENDARS',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        calendarAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Could not load calendars.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          data: (calendars) => Column(
            children: calendars
                .map((cal) => _buildCalendarRow(cal))
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildCalendarRow(SubCalendarModel cal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            // Name + ID
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cal.label.toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (cal.isPrimary) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Primary',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Star icon
            const Icon(
              Icons.star_border_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.sm),

            // SYNC toggle button
            GestureDetector(
              onTap: () => ref
                  .read(subCalendarListProvider.notifier)
                  .toggleSync(cal.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cal.isSyncOn ? AppColors.primary : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SYNC',
                      style: TextStyle(
                        color: cal.isSyncOn ? Colors.white : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      cal.isSyncOn
                          ? Icons.sync_rounded
                          : Icons.sync_disabled_rounded,
                      size: 13,
                      color: cal.isSyncOn ? Colors.white : AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pro tip banner ─────────────────────────────────────────────────────────

  Widget _buildProTipBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        'PRO TIP: TOGGLE SYNC OFF FOR NON-ESSENTIAL CALENDARS TO KEEP YOUR MISSION TIMELINE CLEAN.',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.2,
          height: 1.5,
        ),
      ),
    );
  }

  // ── Save Changes button ────────────────────────────────────────────────────

  Widget _buildSaveButton(
    BuildContext context,
    AsyncValue<List<SubCalendarModel>> calendarAsync,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: calendarAsync.hasValue
            ? () => _showSavedDialog(context)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A2B5E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'SAVE CHANGES',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  // ── Sync saved dialog ─────────────────────────────────────────────────────

  void _showSavedDialog(BuildContext outerContext) {
    showDialog<void>(
      context: outerContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sync Settings Saved!',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your calendar sync preferences have been updated. Ready to explore your trips?',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    outerContext.go('/trips');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2B5E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'SEE YOUR TRIPS',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Done',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Disconnect confirm ─────────────────────────────────────────────────────

  void _confirmDisconnect(BuildContext outerContext) {
    showDialog<void>(
      context: outerContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          title: Text(
            'Disconnect Calendar?',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Your Google Calendar will be disconnected.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ref
                    .read(googleCalendarConnectionProvider.notifier)
                    .disconnect();
                if (outerContext.mounted) outerContext.go('/calendar');
              },
              child: Text(
                'Disconnect',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
