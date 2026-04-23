// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR INTEGRATION SCREEN
// ─────────────────────────────────────────────────────────────────────────────
//
// SCREEN LAYOUT (top → bottom):
//   1. OmvrtiAppBar (showBack: true)
//   2. Blue gradient section:
//        • "Calendar Integration" banner title (centered, white)
//        • White card containing:
//            – "Select Your Calendar" title + subtitle
//            – Dynamic list of vendor rows (from API)
//            – Each row: PNG icon + displayName + chevron
//            – Thin dividers between rows
//
// DATA FLOW:
//   API GET /api/calendar/connections/vendors
//     → CalendarService.fetchVendors()
//     → calendarVendorsProvider (FutureProvider)
//     → UI renders list dynamically from List<CalendarVendor>
//
// ICON CONVENTION:
//   Each vendor's icon is loaded from assets using its `name` field:
//   name = "google" → assets/images/calendar/google_calendar.png
//   name = "apple"  → assets/images/calendar/apple_calendar.png
//
// DYNAMIC UI CONCEPT:
//   We use ListView.separated() instead of hardcoded rows.
//   As the API returns more or fewer vendors, the UI adapts automatically.
//   No if/else per vendor — the data drives everything.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/calendar/model/calendar_vendor_model.dart';
import 'package:omvrti_app/features/calendar/viewmodel/calendar_viewmodel.dart';

class CalendarIntegrationScreen extends ConsumerStatefulWidget {
  const CalendarIntegrationScreen({super.key});

  @override
  ConsumerState<CalendarIntegrationScreen> createState() =>
      _CalendarIntegrationScreenState();
}

class _CalendarIntegrationScreenState
    extends ConsumerState<CalendarIntegrationScreen> {
  @override
  Widget build(BuildContext context) {
    final vendorsAsync = ref.watch(calendarVendorsProvider);

    // Navigate to alert screen on successful OAuth, show error snackbar on failure
    ref.listen<GoogleConnectionState>(
      googleCalendarConnectionProvider,
      (previous, next) {
        if (next.isSuccess && context.mounted) {
          ref.read(googleCalendarConnectionProvider.notifier).reset();
          context.go('/autopilot/alert');
        } else if (next.isError && context.mounted) {
          final msg = next.errorMessage ?? 'Connection failed. Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
          );
          ref.read(googleCalendarConnectionProvider.notifier).reset();
        }
      },
    );

    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const OmvrtiAppBar(showBack: true),

            Expanded(
              child: vendorsAsync.when(
                loading: () => _buildLoadingState(),
                error: (error, _) => _buildErrorState(context, error),
                data: (vendors) => _buildContent(context, vendors),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOADING STATE — Skeleton shimmer effect
  // ─────────────────────────────────────────────────────────────────────────
  //
  // Shows placeholder rows while the API is fetching.
  // Using a shimmer-like animated container gives a better UX than
  // a centered spinner — the user can see the layout is about to appear.
  //
  // We show 5 placeholder rows (matching the expected vendor count).

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _buildBlueBannerShell(
            // Pass a shimmer placeholder as the card content
            child: _buildShimmerCard(),
          ),
        ],
      ),
    );
  }

  // Shimmer card — shows animated pulsing gray rows
  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Select Your Calendar" placeholder
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 180, height: 18),
                const SizedBox(height: 6),
                _shimmerBox(width: 220, height: 13),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // 5 placeholder vendor rows
          ...List.generate(5, (index) => _buildShimmerRow(index)),
        ],
      ),
    );
  }

  Widget _buildShimmerRow(int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Icon placeholder
              _shimmerBox(width: 38, height: 38, radius: 8),
              const SizedBox(width: AppSpacing.md),
              // Text placeholder
              Expanded(child: _shimmerBox(width: double.infinity, height: 16)),
              const SizedBox(width: AppSpacing.md),
              // Chevron placeholder
              _shimmerBox(width: 16, height: 16, radius: 4),
            ],
          ),
        ),
        if (index < 4)
          const Divider(
            height: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
            color: Color(0xFFEEEEEE),
          ),
      ],
    );
  }

  // Animated shimmer box — pulses between two gray shades
  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return _ShimmerBox(width: width, height: height, radius: radius);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ERROR STATE — with retry button
  // ─────────────────────────────────────────────────────────────────────────
  //
  // Shows the error message and a "Try Again" button.
  // Tapping retry calls ref.invalidate(calendarVendorsProvider) which
  // triggers a fresh API call — the provider resets to loading state.
  //
  // ref.invalidate() is Riverpod's way of forcing a re-fetch.
  // It's equivalent to "refresh" — clears the cached value and re-runs.

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Could not load calendars',
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              error.toString().replaceAll('Exception: ', ''),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Retry button — invalidates the provider to re-fetch
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(calendarVendorsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MAIN CONTENT
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, List<CalendarVendor> vendors) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Blue gradient section with white card inside
          _buildBlueBannerShell(
            child: _buildVendorCard(context, vendors),
          ),
        ],
      ),
    );
  }

  // ── Blue gradient shell — wraps the white card ─────────────────────────────
  //
  // Reused by both loading and success states to keep visual consistency.
  // Contains the "Calendar Integration" banner title at the top.

  Widget _buildBlueBannerShell({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Fades from solid primary blue → transparent (page background)
          colors: [AppColors.primary, AppColors.pageBackground],
          stops: const [0.0, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.xl),
          topRight: Radius.circular(AppSpacing.xl),
        ),
      ),
      child: Column(
        children: [
          // ── "Calendar Integration" banner ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Text(
              'Calendar Integration',
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // ── White vendor list card ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: VENDOR CARD (white card with all vendor rows)
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Structure:
  //   "Select Your Calendar" title + subtitle
  //   Thin divider
  //   [Vendor row] × N    ← dynamic, from API
  //
  // Using ListView.builder in shrinkWrap mode because:
  //   → The number of rows is dynamic (comes from API)
  //   → shrinkWrap: true + NeverScrollableScrollPhysics lets the outer
  //     SingleChildScrollView handle scrolling — avoids nested scroll conflicts

  Widget _buildVendorCard(
    BuildContext context,
    List<CalendarVendor> vendors,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Header: "Select Your Calendar" ───────────────────────────
            _buildCardHeader(),

            // Divider between header and list
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // ── Dynamic vendor rows ───────────────────────────────────────
            // ListView.builder creates rows on demand — efficient for
            // any number of vendors without hardcoding anything.
            ListView.separated(
              // shrinkWrap: tells ListView to size itself to its content
              // (not expand to fill remaining screen height).
              // Required when ListView is inside a Column/SingleChildScrollView.
              shrinkWrap: true,

              // NeverScrollableScrollPhysics: disables ListView's own scroll.
              // The outer SingleChildScrollView handles all scrolling.
              // Without this, Flutter throws a "unbounded height" error.
              physics: const NeverScrollableScrollPhysics(),

              itemCount: vendors.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
                color: Color(0xFFEEEEEE),
              ),
              itemBuilder: (context, index) {
                final vendor = vendors[index];
                return _buildVendorRow(context, vendor);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Card header: "Select Your Calendar" ───────────────────────────────────

  Widget _buildCardHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Calendar',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a calendar to connect',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: SINGLE VENDOR ROW
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Layout:
  //   [PNG icon 38×38]  [Bold vendor name] Calendar  >
  //
  // The display name from the API is already formatted:
  //   displayName = "Google Calendar" → shown as-is
  //
  // But the design shows "Google" bold and "Calendar" regular weight.
  // We achieve this with RichText + TextSpan styling.
  //
  // ICON LOADING:
  //   Image.asset() loads from: assets/images/calendar/{name}_calendar.png
  //   errorBuilder provides a fallback icon if the asset is missing —
  //   this prevents a crash during development when assets aren't all added yet.

  Widget _buildVendorRow(BuildContext context, CalendarVendor vendor) {
    final connectionState = ref.watch(googleCalendarConnectionProvider);
    final isConnecting = connectionState.isConnecting;
    final isGoogle = vendor.name.toLowerCase() == 'google';
    final isThisRowLoading = isGoogle && isConnecting;
    final isDisabled = isConnecting && !isGoogle;

    return InkWell(
      onTap: isConnecting
          ? null
          : () {
              if (isGoogle) {
                ref
                    .read(googleCalendarConnectionProvider.notifier)
                    .connect();
              } else {
                _showVendorSelectedSnackBar(context, vendor.displayName);
              }
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: Row(
            children: [
              _buildVendorIcon(vendor),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildVendorName(vendor.displayName)),
              if (isThisRowLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Vendor icon with graceful fallback ─────────────────────────────────────

  Widget _buildVendorIcon(CalendarVendor vendor) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(
        // Uses the computed getter from CalendarVendor:
        // e.g. assets/images/calendar/google_calendar.png
        vendor.iconAssetPath,
        width: 38,
        height: 38,
        fit: BoxFit.contain,

        // FALLBACK: if the PNG asset is missing (during development),
        // show a colored circle with the first letter of the vendor name.
        // This prevents crashes and still looks reasonable.
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              // Generate a color from the vendor name for visual variety
              color: _vendorColor(vendor.name).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                vendor.name[0].toUpperCase(), // First letter as placeholder
                style: AppTextStyles.h4.copyWith(
                  color: _vendorColor(vendor.name),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Vendor display name: "Google" bold + " Calendar" regular ──────────────
  //
  // The design shows the brand name in bold and "Calendar" in regular weight.
  // Strategy: split displayName at the FIRST space.
  //   "Google Calendar" → boldPart = "Google", regularPart = " Calendar"
  //   "Microsoft Teams Calendar" → boldPart = "Microsoft", regularPart = " Teams Calendar"
  //
  // RichText lets us mix text styles in a single text element.

  Widget _buildVendorName(String displayName) {
    // Find the first space — everything before is the brand name
    final spaceIndex = displayName.indexOf(' ');

    if (spaceIndex == -1) {
      // No space found — show the whole name in bold
      return Text(
        displayName,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      );
    }

    final boldPart = displayName.substring(0, spaceIndex);           // "Google"
    final regularPart = displayName.substring(spaceIndex);           // " Calendar"

    return RichText(
      text: TextSpan(
        children: [
          // Brand name — bold
          TextSpan(
            text: boldPart,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          // " Calendar" (or rest of name) — regular weight
          TextSpan(
            text: regularPart,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Vendor color generator (for fallback icon) ─────────────────────────────
  //
  // Maps known vendor names to their brand colors.
  // Falls back to primary blue for unknown vendors.

  Color _vendorColor(String name) {
    const Map<String, Color> vendorColors = {
      'google': Color(0xFF4285F4),      // Google Blue
      'apple': Color(0xFF555555),       // Apple Dark Gray
      'outlook': Color(0xFF0078D4),     // Microsoft Blue
      'calendly': Color(0xFF006BFF),    // Calendly Blue
      'thunderbird': Color(0xFF0A84FF), // Thunderbird Blue
      'zoho': Color(0xFFE42527),        // Zoho Red
      'teams': Color(0xFF6264A7),       // Teams Purple
      'slack': Color(0xFF4A154B),       // Slack Purple
    };
    return vendorColors[name.toLowerCase()] ?? AppColors.primary;
  }

  // ── Snackbar for vendor tap (temporary until OAuth flow is built) ──────────

  void _showVendorSelectedSnackBar(BuildContext context, String vendorName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting to $vendorName...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShimmerBox — animated pulsing placeholder widget
// ─────────────────────────────────────────────────────────────────────────────
//
// CONCEPT: AnimationController + AnimatedBuilder
//   A separate StatefulWidget manages the shimmer animation.
//   It animates opacity between 0.3 and 0.7 creating a pulsing effect.
//
// WHY a separate widget (not inline)?
//   → The animation needs its own initState/dispose lifecycle.
//   → CalendarIntegrationScreen is a ConsumerWidget (stateless) — it can't
//     hold an AnimationController directly.
//   → Extracting to its own widget is the clean, correct Flutter pattern.

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true); // oscillates 0→1→0→1 continuously

    // Tween maps the controller's 0→1 to opacity 0.3→0.7
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}