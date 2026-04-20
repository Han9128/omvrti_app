import 'package:omvrti_app/features/autopilot/model/trip_model.dart';

// CalendarStatus represents every possible state of the calendar connection flow.
// Using an enum instead of multiple booleans prevents impossible states —
// the calendar can only be in ONE of these states at any given moment.
enum CalendarStatus {
  idle,          // default — nothing happening, button ready to tap
  connecting,    // OAuth consent screen is open / user approving
  fetchingTrips, // signed in successfully, now calling Calendar API
  connected,     // trip found and parsed, ready to navigate
  error,         // something failed — errorMessage will explain why
}

class HomeState {
  final String userName;
  final String greeting;
  final int rewardPoints;

  // Single status field replaces the old isLoading + isCalendarConnected booleans
  final CalendarStatus calendarStatus;

  // The trip parsed from the calendar event.
  // null until calendarStatus == connected.
  // Passed to the Alert Screen when navigation happens.
  final TripModel? fetchedTrip;

  // Shown in the error banner when calendarStatus == error
  final String? errorMessage;

  const HomeState({
    this.userName = '',
    this.greeting = 'Good Morning',
    this.rewardPoints = 0,
    this.calendarStatus = CalendarStatus.idle,
    this.fetchedTrip,
    this.errorMessage,
  });

  // Convenience getters make UI code more readable
  bool get isConnecting => calendarStatus == CalendarStatus.connecting;
  bool get isFetchingTrips => calendarStatus == CalendarStatus.fetchingTrips;
  bool get isCalendarLoading =>
      calendarStatus == CalendarStatus.connecting ||
      calendarStatus == CalendarStatus.fetchingTrips;
  bool get isCalendarConnected => calendarStatus == CalendarStatus.connected;
  bool get hasError => calendarStatus == CalendarStatus.error;

  // Label shown inside the import button during loading states
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
    String? greeting,
    int? rewardPoints,
    CalendarStatus? calendarStatus,
    Object? fetchedTrip = _undefined,
    Object? errorMessage = _undefined,
  }) {
    return HomeState(
      userName: userName ?? this.userName,
      greeting: greeting ?? this.greeting,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      calendarStatus: calendarStatus ?? this.calendarStatus,
      fetchedTrip: fetchedTrip == _undefined
          ? this.fetchedTrip
          : fetchedTrip as TripModel?,
      errorMessage: errorMessage == _undefined
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}