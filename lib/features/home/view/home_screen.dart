import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/home/model/home_state.dart';
import 'package:omvrti_app/features/home/view/widgets/calendar_bottom_sheet.dart';
import 'package:omvrti_app/features/home/viewmodel/home_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for when a trip is successfully fetched from the calendar.
    // When fetchedTrip becomes non-null, navigate to the Alert Screen.
    //
    // We use ref.listen (not ref.watch) because navigation is a side effect —
    // it doesn't affect what we display, it's an action we perform.
    ref.listen<HomeState>(homeProvider, (previous, next) {
      // Only navigate when the trip JUST became available
      // (previous had no trip, next has a trip)
      if (previous?.fetchedTrip == null && next.fetchedTrip != null) {
        // Navigate to Alert Screen.
        // The Alert Screen currently uses its own provider to fetch trip data.
        // TODO: When we refactor the Alert Screen, pass the trip via extra:
        // context.go('/autopilot/alert', extra: next.fetchedTrip);
        context.go('/autopilot/alert');
      }
    });

    final homeState = ref.watch(homeProvider);

    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OmvrtiAppBar(),
            Expanded(
              child: _buildContent(homeState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingCard(state),
          const SizedBox(height: AppSpacing.lg),
          _buildEmptyStateCard(state),
          const SizedBox(height: AppSpacing.lg),
          _buildRewardsCard(state),
          const SizedBox(height: AppSpacing.lg),
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  // ── 1. Greeting Card ────────────────────────────────────────────────────────

  Widget _buildGreetingCard(HomeState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A3C8F),
            Color(0xFF2756C5),
            Color(0xFF1E4DB7),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 30,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.greeting.toUpperCase(),
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 1.2,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.userName.isEmpty ? 'Traveler' : state.userName,
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              "No upcoming trips · Let's fix that!",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.75),
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),

                // Plane route arc
                SizedBox(
                  height: 70,
                  width: double.infinity,
                  child: CustomPaint(painter: _PlaneRoutePainter()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Empty State Card ─────────────────────────────────────────────────────

  Widget _buildEmptyStateCard(HomeState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.home_outlined,
              color: Color(0xFF1A3C8F),
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your travel home',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Add your first trip to get started.\nImport from calendar or add manually.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Import from Calendar button ──────────────────────────────────
          // Shows the bottom sheet — does NOT directly trigger OAuth.
          // The user sees the consent sheet first, then confirms.
          _buildCalendarButton(state),
          const SizedBox(height: AppSpacing.sm),
          _buildManualButton(),
        ],
      ),
    );
  }

  Widget _buildCalendarButton(HomeState state) {
    return GestureDetector(
      onTap: state.isCalendarLoading
          ? null
          // Show the bottom sheet — user confirms before OAuth launches
          : () => CalendarBottomSheet.showAsBottomSheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3C8F),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: state.isCalendarLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // Label changes based on current loading phase
                          state.calendarButtonLabel,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Connect and sync automatically',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to manual trip entry screen
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.pageBackground, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0EE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add trip manually',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Enter your trip details yourself',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.pageBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Rewards Card ─────────────────────────────────────────────────────────

  Widget _buildRewardsCard(HomeState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF3CD), Color(0xFFFFE082)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OmVrti Rewards',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: state.rewardPoints / 1000,
                          backgroundColor: AppColors.pageBackground,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.warning,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${state.rewardPoints} pts',
                      style: AppTextStyles.label.copyWith(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Earn on your first booking',
                  style: AppTextStyles.label.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }

  // ── 4. Quick Actions Grid ───────────────────────────────────────────────────

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ACTIONS',
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.8,
            children: [
              _buildActionTile(
                label: 'Book Flight',
                icon: Icons.flight_takeoff_rounded,
                iconColor: const Color(0xFF1A3C8F),
                bgColor: const Color(0xFFF7F8FF),
                iconBgColor: const Color(0xFFE8EEFF),
                onTap: () {},
              ),
              _buildActionTile(
                label: 'Book Hotel',
                icon: Icons.hotel_outlined,
                iconColor: AppColors.accent,
                bgColor: const Color(0xFFFFF8F7),
                iconBgColor: const Color(0xFFFFE8E5),
                onTap: () {},
              ),
              _buildActionTile(
                label: 'Car Rental',
                icon: Icons.directions_car_outlined,
                iconColor: AppColors.success,
                bgColor: const Color(0xFFF3FFF8),
                iconBgColor: const Color(0xFFD6F5E3),
                onTap: () {},
              ),
              _buildActionTile(
                label: 'Expense Report',
                icon: Icons.receipt_long_outlined,
                iconColor: AppColors.warning,
                bgColor: const Color(0xFFFFFBF0),
                iconBgColor: const Color(0xFFFFF0CC),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PLANE ROUTE PAINTER — same as before
// ─────────────────────────────────────────────────────────────────────────────
class _PlaneRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final arcPath = Path()
      ..moveTo(w * 0.08, h * 0.75)
      ..quadraticBezierTo(w * 0.5, -h * 0.3, w * 0.92, h * 0.45);

    _drawDashedPath(
      canvas, arcPath,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    final dotPaint = Paint()..style = PaintingStyle.fill;
    dotPaint.color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(Offset(w * 0.08, h * 0.75), 4, dotPaint);
    dotPaint.color = Colors.white;
    canvas.drawCircle(Offset(w * 0.08, h * 0.75), 2, dotPaint);
    dotPaint.color = const Color(0xFFCC3300).withOpacity(0.9);
    canvas.drawCircle(Offset(w * 0.92, h * 0.45), 4, dotPaint);
    dotPaint.color = Colors.white;
    canvas.drawCircle(Offset(w * 0.92, h * 0.45), 2, dotPaint);

    canvas.save();
    canvas.translate(w * 0.5, h * 0.18);
    canvas.rotate(-0.2);
    final p = Paint()..color = Colors.white.withOpacity(0.95)..style = PaintingStyle.fill;
    canvas.drawPath(Path()..moveTo(-14,0)..lineTo(14,0)..lineTo(12,-2)..lineTo(10,0)..lineTo(12,2)..lineTo(14,0), p);
    canvas.drawPath(Path()..moveTo(14,0)..lineTo(20,-1.5)..lineTo(20,1.5)..close(), p);
    canvas.drawPath(Path()..moveTo(2,0)..lineTo(8,-9)..lineTo(10,-9)..lineTo(6,0)..lineTo(10,9)..lineTo(8,9)..close(), p..color = Colors.white.withOpacity(0.9));
    canvas.drawPath(Path()..moveTo(-10,0)..lineTo(-6,-6)..lineTo(-4,-6)..lineTo(-6,0)..close(), p..color = Colors.white.withOpacity(0.85));
    canvas.restore();

    final labelStyle = TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5);
    _drawText(canvas, 'SFO', Offset(w * 0.04, h * 0.82), labelStyle);
    _drawText(canvas, 'JFK', Offset(w * 0.88, h * 0.52), labelStyle);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, position);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      bool drawing = true;
      while (distance < metric.length) {
        final segLen = drawing ? 6.0 : 4.0;
        final next = (distance + segLen).clamp(0.0, metric.length);
        if (drawing) canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}