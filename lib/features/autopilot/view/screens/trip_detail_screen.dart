import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/calendar/model/calendar_event_model.dart';

class TripDetailScreen extends StatelessWidget {
  final CalendarEventModel trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
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
                    _buildBannerCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              trip.title.isNotEmpty ? trip.title : 'Trip Details',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
            ),
            child: _buildContentCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Events',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trip.tripEvents.length} event${trip.tripEvents.length == 1 ? '' : 's'}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          if (trip.tripEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'No events found for this trip.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < trip.tripEvents.length; i++) ...[
                  _buildEventCard(trip.tripEvents[i]),
                  if (i < trip.tripEvents.length - 1)
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                ],
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(TripEventModel event) {
    final timeRange = _formatTimeRange(event);
    final venue = event.venueName ?? '';
    final address = event.addressLine1 ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSequenceBadge(event.sequenceOrder),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title.isNotEmpty ? event.title : 'Untitled Event',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (event.allDay) ...[
                  const SizedBox(height: 2),
                  Text(
                    'All day',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ] else if (timeRange.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    timeRange,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
                if (venue.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    venue,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceBadge(int order) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$order',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatTimeRange(TripEventModel event) {
    final start = event.startTime;
    final end = event.endTime;
    if (start == null) return '';
    final dateFmt = DateFormat('d MMM yyyy');
    final timeFmt = DateFormat('h:mm a');
    final dateStr = dateFmt.format(start);
    if (end == null) return '$dateStr, ${timeFmt.format(start)}';
    if (_isSameDay(start, end)) {
      return '$dateStr, ${timeFmt.format(start)} – ${timeFmt.format(end)}';
    }
    return '${dateFmt.format(start)}, ${timeFmt.format(start)} – ${dateFmt.format(end)}, ${timeFmt.format(end)}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
