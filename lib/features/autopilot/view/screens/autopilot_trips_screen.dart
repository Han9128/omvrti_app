import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/calendar/model/calendar_event_model.dart';
import 'package:omvrti_app/features/calendar/viewmodel/calendar_viewmodel.dart';

// ─── Why ConsumerStatefulWidget here? ───────────────────────────────────────
// We need a TabController which requires a TickerProvider (vsync).
// TickerProvider is only available through the SingleTickerProviderStateMixin,
// which requires a StatefulWidget. So we use ConsumerStatefulWidget (Riverpod's
// stateful variant) to get both: local state/lifecycle AND provider access.
// ────────────────────────────────────────────────────────────────────────────
class AutopilotTripsScreen extends ConsumerStatefulWidget {
  const AutopilotTripsScreen({super.key});

  @override
  ConsumerState<AutopilotTripsScreen> createState() =>
      _AutopilotTripsScreenState();
}

class _AutopilotTripsScreenState extends ConsumerState<AutopilotTripsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // ── Colors scoped to this screen ────────────────────────────────────────
  // Defined as constants here instead of magic hex strings scattered through
  // the build method. In a larger project these would live in AppColors.
  static const Color _acceptGreen = Color(0xFF27AE60);
  static const Color _tabIndicatorOrange = Color(0xFFE85C2A);

  @override
  void initState() {
    super.initState();
    // length: 3 → Accepted | Pending | Rejected
    // initialIndex: 1 → open on "Pending" tab by default (matches the design)
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    // Always dispose controllers to free resources and prevent memory leaks
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider — this rebuilds the widget whenever the async state
    // changes (loading → data → error).
    final eventsAsync = ref.watch(calendarEventsProvider);

    // maybeWhen lets us safely extract a value from AsyncValue.
    // We only care about the data case for total count; otherwise default to 0.
    final int total = eventsAsync.maybeWhen(
      data: (events) => events.length,
      orElse: () => 0,
    );

    // ── Layout overview ──────────────────────────────────────────────────
    //
    //  Screen background: pageBackground (light gray) everywhere
    //
    //  ┌─ AppBar ────────────────────────────────────────┐
    //  └─────────────────────────────────────────────────┘
    //    ← 16px gap, pageBackground shows here →
    //    ┌── Banner card (16px inset left & right) ──────┐
    //    │  gradient: primary(blue) → pageBackground     │
    //    │  ┌─ Title "Autopilot Trips" ─────────────────┐│
    //    │  ├─ Progress card ────────────────────────────┤│
    //    │  ├─ Tab bar ──────────────────────────────────┤│
    //    │  ├─ Divider ──────────────────────────────────┤│
    //    │  └─ Trip list (scrollable) ─────────────────── ││
    //    └───────────────────────────────────────────────┘
    //    ← 16px gap, pageBackground shows here →
    //  ┌─ Bottom nav ────────────────────────────────────┐
    //  └─────────────────────────────────────────────────┘
    //
    return ColoredBox(
      // The whole screen behind everything is pageBackground (light gray).
      // This is what peeks through on the sides and below the banner card.
      color: AppColors.pageBackground,
      child: SafeArea(
        bottom: false, // bottom nav bar handles its own safe-area padding
        top: false,    // OmvrtiAppBar handles top safe-area internally
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── AppBar: back arrow + logo + avatar ──────────────────────
            const OmvrtiAppBar(showBack: true),

            // ── 16px gap between AppBar and banner ──────────────────────
            // pageBackground shows through here, giving the card a "lifted"
            // look — it's not stuck to the AppBar.
            const SizedBox(height: AppSpacing.lg),

            // ── Banner card: 16px inset from both sides ──────────────────
            // Expanded makes the card fill ALL remaining vertical space so
            // the tab list inside can scroll without causing an overflow.
            Expanded(
              child: Padding(
                // Only left and right padding — top is covered by the
                // SizedBox above; bottom padding is not needed because the
                // banner visually fades into pageBackground via the gradient.
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, // 16px each side
                ),
                child: _buildBannerCard(total, eventsAsync),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── WIDGET: Banner card ─────────────────────────────────────────────────
  // The rounded gradient card that holds ALL screen content below the AppBar.
  //
  // Gradient explanation:
  //   stop 0.0 → AppColors.primary  (solid blue at the very top)
  //   stop 1.0 → AppColors.pageBackground  (fades to light gray at bottom)
  //
  // This gives the banner a "sky fading to ground" feel and makes the
  // trip cards appear to float on the light gray background naturally.
  Widget _buildBannerCard(
    int total,
    AsyncValue<List<CalendarEventModel>> eventsAsync,
  ) {
    return Container(
      // ClipRRect is not needed here — Container's borderRadius already clips
      // its own decoration. But child content can overflow rounded corners,
      // so we use clipBehavior to enforce the clip on child widgets too.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.xxl), // 24px rounded
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,       // solid blue at top
            AppColors.pageBackground, // light gray at bottom
          ],
          // stops control where each color is "fully reached".
          // 0.25 means the blue is full-strength for the top 25% of the card,
          // then it gradually fades to pageBackground by 1.0 (the bottom).
          stops: [0.0, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Title inside the blue gradient zone ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              'Autopilot Trips',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // ── Progress card: white card inside the banner ───────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _buildProgressCard(total),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Tab bar ───────────────────────────────────────────────────
          _buildTabBar(),

          // ── Divider separates tab bar from list content ───────────────
          const Divider(height: 1, thickness: 1, color: Color(0xFFDDDDDD)),

          // ── Tab content fills remaining banner space ──────────────────
          // Expanded is crucial here: without it, Column has infinite height
          // and the TabBarView inside would have no bounded height to render.
          Expanded(
            child: _buildTabBarView(eventsAsync),
          ),
        ],
      ),
    );
  }

  // ── WIDGET: Progress card ───────────────────────────────────────────────
  // Shows "Accepted: X out of Y", a progress bar, and the Accept All button.
  // [total] is the number of events from the API.
  Widget _buildProgressCard(int total) {
    // Hard-coded to 0 for now — will be driven by state when accept logic
    // is wired up (e.g. a StateNotifierProvider tracking accepted IDs).
    const int accepted = 0;

    // Progress value must be between 0.0 and 1.0 for LinearProgressIndicator.
    // We guard against division by zero when total is 0.
    final double progress = total == 0 ? 0.0 : accepted / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            // withValues is the null-safe replacement for withOpacity
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: label + Accept All button ─────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  'Accepted: $accepted out of $total',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Accept All — pill shaped green button
              ElevatedButton(
                onPressed: () {
                  // TODO: wire up accept-all logic via provider
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _acceptGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  // shrinkWrap removes the default minimum 48px tap area,
                  // letting the button size itself to its content + padding.
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    // Large radius → pill shape
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
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Progress bar ────────────────────────────────────────────
          // ClipRRect rounds the corners of the LinearProgressIndicator,
          // because LinearProgressIndicator itself has no borderRadius param.
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE0E0E0), // gray track
              valueColor: const AlwaysStoppedAnimation<Color>(_acceptGreen),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ── WIDGET: Tab bar ─────────────────────────────────────────────────────
  // Three tabs: Accepted | Pending | Rejected
  // Sits on white background; orange underline indicator.
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.textMuted,
      indicatorColor: _tabIndicatorOrange,
      indicatorWeight: 3,
      // transparent divider removes the default grey line TabBar adds
      dividerColor: Colors.transparent,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: AppTextStyles.bodySmall,
      tabs: const [
        Tab(text: 'Accepted'),
        Tab(text: 'Pending'),
        Tab(text: 'Rejected'),
      ],
    );
  }

  // ── WIDGET: Tab content ─────────────────────────────────────────────────
  // Each tab gets its own view. Only "Pending" shows real API data.
  Widget _buildTabBarView(AsyncValue<List<CalendarEventModel>> eventsAsync) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab 0: Accepted — empty for now
        _buildEmptyState('No accepted trips yet.'),

        // Tab 1: Pending — driven by API data
        _buildPendingTab(eventsAsync),

        // Tab 2: Rejected — empty for now
        _buildEmptyState('No rejected trips.'),
      ],
    );
  }

  // ── WIDGET: Pending tab content ─────────────────────────────────────────
  // Handles all three AsyncValue states: loading, error, data.
  Widget _buildPendingTab(AsyncValue<List<CalendarEventModel>> eventsAsync) {
    return eventsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => _buildEmptyState(
        'Could not load trips.\nMake sure your Google Calendar is connected.',
      ),
      data: (events) {
        if (events.isEmpty) {
          return _buildEmptyState('No trips found in your calendar.');
        }

        // ListView.separated automatically inserts a separator widget between
        // each item — cleaner than adding SizedBox inside itemBuilder.
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, index) => _buildTripCard(events[index]),
        );
      },
    );
  }

  // ── WIDGET: Empty state ─────────────────────────────────────────────────
  // Shown when a tab has no content or an error occurs.
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }

  // ── WIDGET: Individual trip card ────────────────────────────────────────
  // Displays one CalendarEventModel as a card matching the design.
  // Layout:
  //   ┌───────────────────────────────────┐
  //   │ Event title            View details│
  //   │ 1 Jun – 5 Jun 2026                │
  //   │ New York, NY, USA                 │
  //   │                                   │
  //   │ [  Edit  ]            [  Accept  ]│
  //   └───────────────────────────────────┘
  Widget _buildTripCard(CalendarEventModel event) {
    final String dateRange = _formatDateRange(event);
    final String location = event.location ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        // Subtle shadow only — no visible border — matches the design
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // card height wraps its content
        children: [
          // ── Title row + "View details" link ──────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  // Graceful fallback if summary is empty
                  event.summary.isNotEmpty ? event.summary : 'Untitled Event',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () {
                  // TODO: navigate to event detail screen
                },
                child: Text(
                  'View details',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary, // blue link colour
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // ── Date range (only shown if available) ─────────────────
          if (dateRange.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              dateRange,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // ── Location (only shown if available) ───────────────────
          if (location.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              location,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // ── Action buttons row ────────────────────────────────────
          Row(
            children: [
              // Edit — outlined pill button (left)
              OutlinedButton(
                onPressed: () {
                  // TODO: navigate to edit screen for this event
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCCCCCC)),
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // pill shape
                  ),
                ),
                child: Text(
                  'Edit',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Spacer pushes Accept to the far right
              const Spacer(),

              // Accept — filled orange-red pill button (right)
              ElevatedButton(
                onPressed: () {
                  // TODO: trigger accept logic via provider
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tabIndicatorOrange, // same orange as tab
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // pill shape
                  ),
                ),
                child: Text(
                  'Accept',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── HELPER: Format date range string ────────────────────────────────────
  // Produces human-readable strings like:
  //   "1 Jun – 5 Jun 2026"   (same year, different days)
  //   "31 Dec 2025 – 2 Jan 2026" (different years)
  //   "1 Jun 2026"            (single-day event)
  String _formatDateRange(CalendarEventModel event) {
    // Calendar events can come as full datetimes or date-only strings.
    // We prefer the datetime field but fall back to date-only.
    final DateTime? start =
        _parseDate(event.startDateTime ?? event.startDate);
    final DateTime? end = _parseDate(event.endDateTime ?? event.endDate);

    if (start == null) return '';

    final DateFormat fullFmt = DateFormat('d MMM yyyy');
    final DateFormat shortFmt = DateFormat('d MMM');

    // Single-day event or end date not available
    if (end == null || _isSameDay(start, end)) return fullFmt.format(start);

    // Same year — omit year from start date to save space
    if (start.year == end.year) {
      return '${shortFmt.format(start)} – ${fullFmt.format(end)}';
    }

    // Different years — show full format for both
    return '${fullFmt.format(start)} – ${fullFmt.format(end)}';
  }

  // Safely parse an ISO date or datetime string. Returns null on failure.
  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  // Returns true if two DateTimes fall on the same calendar day.
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}