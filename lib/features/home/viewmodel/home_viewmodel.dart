import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/autopilot_viewmodel.dart';
import 'package:omvrti_app/features/home/model/home_state.dart';
import 'package:omvrti_app/features/home/service/home_service.dart';
import 'package:omvrti_app/features/home/service/calendar_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

final homeServiceProvider = Provider<HomeService>((ref) => HomeService());

final calendarServiceProvider = Provider<CalendarService>(
  (ref) => CalendarService(),
);

// Using Riverpod 3 NotifierProvider — StateNotifierProvider is removed in v3
final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// HOME NOTIFIER — Riverpod 3 style
// ─────────────────────────────────────────────────────────────────────────────

class HomeNotifier extends Notifier<HomeState> {
  // In Riverpod 3, build() replaces the constructor + super(initialState)
  // It runs once when the provider is first read and sets the initial state
  @override
  HomeState build() {
    return const HomeState();
  }

  // loadUserProfile() — called from initState when screen first mounts
  Future<void> loadUserProfile() async {
    try {
      final homeService = ref.read(homeServiceProvider);
      final profile = await homeService.fetchUserProfile();

      state = state.copyWith(
        userName: profile['userName'] as String,
        // Stats are 0 for a new user — will be populated from real API later
        totalSpend: 0,
        manDaysSaved: 0,
        companySaved: 0,
        rewardsEarned: 0,
        pendingTrips: const [],
      );
    } catch (e) {
      // Non-critical — show defaults if profile load fails
      state = state.copyWith(userName: 'Traveler');
    }
  }

  // connectAndFetchCalendar() — triggered from "Import from Google Calendar"
  // Writes fetched trip into selectedTripProvider so Alert Screen picks it up
  Future<void> connectAndFetchCalendar() async {
    state = state.copyWith(
      calendarStatus: CalendarStatus.connecting,
      errorMessage: null,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(calendarStatus: CalendarStatus.fetchingTrips);

    final calendarService = ref.read(calendarServiceProvider);
    final result = await calendarService.connectAndFetchTrip();

    if (result is CalendarSuccess) {
      // Write to shared bridge provider so Alert Screen uses calendar trip
      ref.read(selectedTripProvider.notifier).setTrip(result.trip);

      state = state.copyWith(
        calendarStatus: CalendarStatus.connected,
        fetchedTrip: result.trip,
      );
    } else if (result is CalendarFailure) {
      final isNoEvents = result.message.contains('No upcoming events') ||
          result.message.contains('No travel events');
      state = state.copyWith(
        calendarStatus:
            isNoEvents ? CalendarStatus.noEvents : CalendarStatus.error,
        errorMessage: result.message,
      );
    }
  }

  void resetCalendarError() {
    state = state.copyWith(
      calendarStatus: CalendarStatus.idle,
      errorMessage: null,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}