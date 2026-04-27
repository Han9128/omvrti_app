import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/calendar/model/calendar_event_model.dart';
import 'package:omvrti_app/features/calendar/viewmodel/calendar_viewmodel.dart';

class AutopilotTripsScreen extends ConsumerStatefulWidget {
  const AutopilotTripsScreen({super.key});

  @override
  ConsumerState<AutopilotTripsScreen> createState() =>
      _AutopilotTripsScreenState();
}

class _AutopilotTripsScreenState extends ConsumerState<AutopilotTripsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider);

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
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    _buildBannerCard(eventsAsync),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard(AsyncValue<List<CalendarEventModel>> eventsAsync) {
    final total = eventsAsync.maybeWhen(
      data: (e) => e.length,
      orElse: () => 0,
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.pageBackground],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.xl),
          topRight: Radius.circular(AppSpacing.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Autopilot Trips',
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
            ),
            child: _buildContentCard(eventsAsync, total),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    AsyncValue<List<CalendarEventModel>> eventsAsync,
    int total,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Accepted header + progress bar ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Accepted : 0 out of $total',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Accept All',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0,
                    backgroundColor: Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF27AE60),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // ── Tabs ──────────────────────────────────────────────────────────
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            dividerColor: Colors.transparent,
            labelStyle: AppTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w700),
            unselectedLabelStyle: AppTextStyles.bodySmall,
            tabs: const [
              Tab(text: 'Accepted'),
              Tab(text: 'Pending'),
              Tab(text: 'Rejected'),
            ],
          ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // ── Tab content (no TabBarView — avoids bounded-height issue) ─────
          _buildTabContent(eventsAsync),
        ],
      ),
    );
  }

  Widget _buildTabContent(AsyncValue<List<CalendarEventModel>> eventsAsync) {
    switch (_tabController.index) {
      case 0:
        return _buildPlaceholder('No accepted trips yet.');
      case 2:
        return _buildPlaceholder('No rejected trips.');
      default: // 1 → Pending
        return eventsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: Text(
                'Could not load trips.\nMake sure your Google Calendar is connected.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
          data: (events) => events.isEmpty
              ? _buildPlaceholder('No trips found in your calendar.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < events.length; i++) ...[
                      _buildTripCard(events[i]),
                      if (i < events.length - 1)
                        const Divider(
                            height: 1, color: Color(0xFFEEEEEE)),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
        );
    }
  }

  Widget _buildPlaceholder(String message) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _buildTripCard(CalendarEventModel event) {
    final dateRange = _formatDateRange(event);
    final location = event.originCity ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.title.isNotEmpty
                        ? event.title
                        : 'Untitled Event',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () => context.push(
                    '/trips/autopilot/detail',
                    extra: event,
                  ),
                  child: Text(
                    'View details',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            if (dateRange.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                dateRange,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
            if (location.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                location,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.accent, width: 1.5),
                      foregroundColor: AppColors.accent,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textWhite,
                      elevation: 0,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(CalendarEventModel event) {
    final start = _parseDate(event.departureDate);
    final end = _parseDate(event.returnDate);
    if (start == null) return '';
    final fmt = DateFormat('d MMM yyyy');
    if (end == null || _isSameDay(start, end)) return fmt.format(start);
    if (start.year == end.year) {
      return '${DateFormat('d MMM').format(start)} – ${fmt.format(end)}';
    }
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
