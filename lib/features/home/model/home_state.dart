import 'package:omvrti_app/features/autopilot/model/trip_model.dart';

enum CalendarStatus {
  idle,
  connecting,
  fetchingTrips,
  connected,
  noEvents, // connected but no travel events found
  error,
}

// Lightweight model for pending trips in "Accept your trip" section
class PendingTrip {
  final String title;
  final String dateRange;
  final String location;

  const PendingTrip({
    required this.title,
    required this.dateRange,
    required this.location,
  });
}

class HomeState {
  final String userName;

  // Stats in the blue header card — all 0 for new user
  final double totalSpend;
  final double manDaysSaved;
  final double companySaved;
  final double rewardsEarned;

  // Calendar connection flow
  final CalendarStatus calendarStatus;
  final TripModel? fetchedTrip;
  final String? errorMessage;

  // Pending trips shown in "Accept your trip" section
  final List<PendingTrip> pendingTrips;

  const HomeState({
    this.userName = '',
    this.totalSpend = 0,
    this.manDaysSaved = 0,
    this.companySaved = 0,
    this.rewardsEarned = 0,
    this.calendarStatus = CalendarStatus.idle,
    this.fetchedTrip,
    this.errorMessage,
    this.pendingTrips = const [],
  });

  bool get isConnecting => calendarStatus == CalendarStatus.connecting;
  bool get isFetchingTrips => calendarStatus == CalendarStatus.fetchingTrips;
  bool get isCalendarLoading =>
      calendarStatus == CalendarStatus.connecting ||
      calendarStatus == CalendarStatus.fetchingTrips;
  bool get isCalendarConnected => calendarStatus == CalendarStatus.connected;
  bool get isNoEvents => calendarStatus == CalendarStatus.noEvents;
  bool get hasError => calendarStatus == CalendarStatus.error;

  String get calendarButtonLabel {
    switch (calendarStatus) {
      case CalendarStatus.connecting:
        return 'Connecting to Google...';
      case CalendarStatus.fetchingTrips:
        return 'Analysing your calendar...';
      default:
        return 'Import from Google Calendar';
    }
  }

  static const _undefined = Object();

  HomeState copyWith({
    String? userName,
    double? totalSpend,
    double? manDaysSaved,
    double? companySaved,
    double? rewardsEarned,
    CalendarStatus? calendarStatus,
    Object? fetchedTrip = _undefined,
    Object? errorMessage = _undefined,
    List<PendingTrip>? pendingTrips,
  }) {
    return HomeState(
      userName: userName ?? this.userName,
      totalSpend: totalSpend ?? this.totalSpend,
      manDaysSaved: manDaysSaved ?? this.manDaysSaved,
      companySaved: companySaved ?? this.companySaved,
      rewardsEarned: rewardsEarned ?? this.rewardsEarned,
      calendarStatus: calendarStatus ?? this.calendarStatus,
      fetchedTrip: fetchedTrip == _undefined
          ? this.fetchedTrip
          : fetchedTrip as TripModel?,
      errorMessage: errorMessage == _undefined
          ? this.errorMessage
          : errorMessage as String?,
      pendingTrips: pendingTrips ?? this.pendingTrips,
    );
  }
}