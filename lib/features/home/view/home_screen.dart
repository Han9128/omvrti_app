import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/home/model/home_state.dart';
import 'package:omvrti_app/features/home/view/widgets/add_meeting_bottom_sheet.dart';
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
  ref.listen<HomeState>(homeProvider, (previous, next) {
    if (previous?.fetchedTrip == null && next.fetchedTrip != null) {
      context.go('/autopilot/alert');
    }
  });

  final state = ref.watch(homeProvider);

  return Scaffold(
    body: ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OmvrtiAppBar(showBack: true),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ─────────────────────────────────────────────
                    // 🔵 BLUE HERO SECTION (FIXED)
                    // ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary,
                              AppColors.pageBackground,
                            ],
                            stops: [0.0, 1.0],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Padding(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), // 👈 adds inner spacing
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildGreeting(state),
      const SizedBox(height: AppSpacing.lg),

      _buildRewardsBanner(state),
      const SizedBox(height: AppSpacing.md),

      _buildStatTiles(state),

      const SizedBox(height: AppSpacing.lg),

      Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.dashboard_customize_outlined,
              color: Colors.white,
              size: 15,
            ),
            const SizedBox(width: 4),
            Text(
              'Add Widget',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                // decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 20),

      _buildUpcomingTripCard(),
    ],
  ),
),                      ),
                    ),

                    // ─────────────────────────────────────────────
                    // ⚪ WHITE SECTION
                    // ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.xxxl,
                      ),
                      child: _buildAcceptTripCard(state),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ── Custom AppBar on gradient background ──────────────────────────────────
  // We can't use OmvrtiAppBar directly because it has a white background.
  // We rebuild it transparent so the gradient shows through.
  // Widget _buildAppBar() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: AppSpacing.lg,
  //       vertical: AppSpacing.md,
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         // Hamburger menu — white on blue
  //         const Icon(Icons.menu, color: Colors.white, size: 28),

  //         // OmVrti.ai logo — white version on blue background
  //         RichText(
  //           text: const TextSpan(
  //             children: [
  //               TextSpan(
  //                 text: 'Om',
  //                 style: TextStyle(
  //                   fontFamily: 'PlusJakartaSans',
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.w800,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               TextSpan(
  //                 text: 'V',
  //                 style: TextStyle(
  //                   fontFamily: 'PlusJakartaSans',
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.w800,
  //                   // Keep the red V even on blue — it's the brand mark
  //                   color: Color(0xFFFF6B6B),
  //                 ),
  //               ),
  //               TextSpan(
  //                 text: 'rti.ai',
  //                 style: TextStyle(
  //                   fontFamily: 'PlusJakartaSans',
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.w800,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         // Avatar — same as before
  //         const CircleAvatar(
  //           radius: 18,
  //           backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ── "Hey, Sam!" greeting ──────────────────────────────────────────────────
  Widget _buildGreeting(HomeState state) {
    final firstName = state.userName.isEmpty
        ? 'Traveler'
        : state.userName.split(' ').first;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Hey, ',
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 26,
            ),
          ),
          TextSpan(
            text: '$firstName!',
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 26,
            ),
          ),
        ],
      ),
    );
  }

  // ── Rewards banner — white card inside the blue zone ─────────────────────
  Widget _buildRewardsBanner(HomeState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Medal icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFFFB800),
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total OmVrti Rewards Earned',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Book early, earn more.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${state.rewardsEarned.toStringAsFixed(0)}',
                style: AppTextStyles.price.copyWith(
                  fontSize: 22,
                  color: AppColors.success,
                ),
              ),
              Text(
                'OmVrti Rewards',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.success,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 3 stat tiles ──────────────────────────────────────────────────────────
  Widget _buildStatTiles(HomeState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            icon: Icons.attach_money_rounded,
            value: '\$${state.totalSpend.toStringAsFixed(0)}',
            label: 'Total Spend',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildStatTile(
            icon: Icons.access_time_rounded,
            value: state.manDaysSaved.toStringAsFixed(1),
            label: 'Man Days Saved',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildStatTile(
            icon: Icons.business_outlined,
            value: '\$${state.companySaved.toStringAsFixed(0)}',
            label: 'Company Saved',
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF4FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 18),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.label.copyWith(fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPCOMING TRIP CARD
  //
  // White rounded card that visually overlaps the blue zone.
  // Because the gradient is the page background, this card naturally
  // appears to sit on top of the blue area and extends into the white zone.
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildUpcomingTripCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Upcoming Trip" + "+ Add a Meeting" red button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Trip',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
              ),
              GestureDetector(
                onTap: () => AddMeetingBottomSheet.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        'Add a Meeting',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Inner trip card with border
          _buildEmptyTripCard(),
          const SizedBox(height: AppSpacing.md),

          // Pagination dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(active: true),
              const SizedBox(width: 6),
              _buildDot(active: false),
              const SizedBox(width: 6),
              _buildDot(active: false),
            ],
          ),
        ],
      ),
    );
  }

  // The empty trip card — just status chips + "No trips yet" message
  // No airport names as requested
  Widget _buildEmptyTripCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Column(
        children: [
          // Status chips row
          Row(
            children: [
              // "● Active" green pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Info chips
              Expanded(
                child: Row(
                  children: [
                    _buildInfoChip(label: 'DEPART', value: '—'),
                    const SizedBox(width: 4),
                    _buildInfoChip(label: 'RETURN', value: '—'),
                    const SizedBox(width: 4),
                    _buildInfoChip(label: 'TRAVELERS', value: '—'),
                    const SizedBox(width: 4),
                    _buildInfoChip(label: 'DAYS AWAY', value: '—'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // "No trips yet" — simple centered message, no airport names
          Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flight_outlined,
                  color: Color(0xFF3B82F6),
                  size: 26,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No trips yet',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap "+ Add a Meeting" to get started',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 7,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required bool active}) {
    return Container(
      width: active ? 10 : 8,
      height: active ? 10 : 8,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : AppColors.textMuted.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACCEPT YOUR TRIP CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAcceptTripCard(HomeState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Accept your trip',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
              ),
              // "Pending Trip" yellow pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFB800).withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Pending Trip',
                  style: AppTextStyles.label.copyWith(
                    color: const Color(0xFF9B6D00),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Empty state for new user
          if (state.pendingTrips.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  'No pending trips',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ...state.pendingTrips.map((trip) => _buildPendingTripRow(trip)),
        ],
      ),
    );
  }

  Widget _buildPendingTripRow(PendingTrip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trip.dateRange}  –  ${trip.location}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}
