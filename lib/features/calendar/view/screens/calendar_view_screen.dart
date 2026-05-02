import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/calendar/model/calendar_event_model.dart';
import 'package:omvrti_app/features/calendar/viewmodel/calendar_viewmodel.dart';

// ── Internal types ────────────────────────────────────────────────────────────

enum _EventType { tripDeparture, tripReturn, calendarEvent }

class _DayEvent {
  final String title;
  final _EventType type;
  final TripEventModel? tripEvent;

  const _DayEvent({required this.title, required this.type, this.tripEvent});
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CalendarViewScreen extends ConsumerStatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  ConsumerState<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends ConsumerState<CalendarViewScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  // ── Event map building ────────────────────────────────────────────────────

  Map<DateTime, List<_DayEvent>> _buildEventMap(List<CalendarEventModel> trips) {
    final map = <DateTime, List<_DayEvent>>{};

    void add(DateTime? dt, _DayEvent event) {
      if (dt == null) return;
      final key = _dateOnly(dt);
      map.putIfAbsent(key, () => []).add(event);
    }

    for (final trip in trips) {
      final name = trip.title.isNotEmpty ? trip.title : 'Trip';
      add(
        _parseDate(trip.departureDate),
        _DayEvent(title: name, type: _EventType.tripDeparture),
      );
      final ret = _parseDate(trip.returnDate);
      final dep = _parseDate(trip.departureDate);
      if (ret != null && !_isSameDay(dep, ret)) {
        add(ret, _DayEvent(title: name, type: _EventType.tripReturn));
      }

      for (final e in trip.tripEvents) {
        add(
          _parseDate(e.eventStartDatetime),
          _DayEvent(
            title: e.title.isNotEmpty ? e.title : 'Event',
            type: _EventType.calendarEvent,
            tripEvent: e,
          ),
        );
      }
    }

    return map;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _isSameDay(DateTime? a, DateTime? b) =>
      a != null &&
      b != null &&
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  // ── Build ──────────────────────────────────────────────────────────────────

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
            'My Calendar',
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
            child: _buildContentCard(eventsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(AsyncValue<List<CalendarEventModel>> eventsAsync) {
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
      child: eventsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        error: (_, __) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Text(
              'Could not load calendar events.\nMake sure your Google Calendar is connected.',
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ),
        ),
        data: (trips) {
          final eventMap = _buildEventMap(trips);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMonthHeader(),
              _buildWeekdayLabels(),
              _buildDayGrid(eventMap),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _buildLegend(),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _buildSelectedDaySection(eventMap),
            ],
          );
        },
      ),
    );
  }

  // ── Month header ──────────────────────────────────────────────────────────

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() {
              _focusedMonth =
                  DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            }),
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(_focusedMonth),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              _focusedMonth =
                  DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            }),
            icon:
                const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Weekday labels ────────────────────────────────────────────────────────

  Widget _buildWeekdayLabels() {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: labels
            .map(
              (l) => Expanded(
                child: Text(
                  l,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ── Day grid ──────────────────────────────────────────────────────────────

  Widget _buildDayGrid(Map<DateTime, List<_DayEvent>> eventMap) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    // weekday: Mon=1 … Sun=7; we want Sun=0 offset
    final startOffset = firstDay.weekday % 7;
    final totalCells = startOffset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final today = _dateOnly(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(rowCount, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNumber = cellIndex - startOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 46));
              }

              final date = DateTime(
                  _focusedMonth.year, _focusedMonth.month, dayNumber);
              final dateKey = _dateOnly(date);
              final isToday = dateKey == today;
              final isSelected = _isSameDay(_selectedDay, date);
              final dayEvents = eventMap[dateKey] ?? [];
              final hasEvents = dayEvents.isNotEmpty;

              // dot colors — show up to 3 distinct type dots
              final dotColors = <Color>{};
              for (final e in dayEvents) {
                dotColors.add(_dotColor(e.type));
                if (dotColors.length == 3) break;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedDay =
                        _isSameDay(_selectedDay, date) ? null : date;
                  }),
                  child: Container(
                    height: 46,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: isToday || isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        if (hasEvents) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: dotColors
                                .map(
                                  (c) => Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected ? Colors.white : c,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Color _dotColor(_EventType type) {
    return switch (type) {
      _EventType.tripDeparture => AppColors.success,
      _EventType.tripReturn => AppColors.accent,
      _EventType.calendarEvent => AppColors.primary,
    };
  }

  // ── Legend ────────────────────────────────────────────────────────────────

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(AppColors.success, 'Departure'),
          const SizedBox(width: AppSpacing.lg),
          _legendItem(AppColors.accent, 'Return'),
          const SizedBox(width: AppSpacing.lg),
          _legendItem(AppColors.primary, 'Event'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Selected day events ───────────────────────────────────────────────────

  Widget _buildSelectedDaySection(Map<DateTime, List<_DayEvent>> eventMap) {
    if (_selectedDay == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'Tap a day to see events',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    final dayKey = _dateOnly(_selectedDay!);
    final dayEvents = eventMap[dayKey] ?? [];
    final formattedDay =
        DateFormat('EEEE, d MMMM yyyy').format(_selectedDay!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm,
          ),
          child: Text(
            formattedDay,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (dayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg,
            ),
            child: Text(
              'No events on this day.',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          )
        else
          for (final e in dayEvents) _buildEventRow(e),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildEventRow(_DayEvent event) {
    final dotColor = _dotColor(event.type);
    final label = switch (event.type) {
      _EventType.tripDeparture => 'Departure',
      _EventType.tripReturn => 'Return',
      _EventType.calendarEvent => 'Event',
    };

    String? timeStr;
    if (event.tripEvent != null) {
      final start = event.tripEvent!.startTime;
      if (start != null && !event.tripEvent!.allDay) {
        timeStr = DateFormat('h:mm a').format(start);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 3),
            decoration:
                BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: dotColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10,
                          color: dotColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (timeStr != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        timeStr,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
