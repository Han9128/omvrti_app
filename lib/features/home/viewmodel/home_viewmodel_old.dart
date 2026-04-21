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

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// HOME NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  Future<void> loadUserProfile() async {
    try {
      final greeting = ref.read(homeServiceProvider).getGreeting();
      final profile = await ref.read(homeServiceProvider).fetchUserProfile();
      state = state.copyWith(
        greeting: greeting,
        userName: profile['userName'] as String,
        rewardPoints: profile['rewardPoints'] as int,
      );
    } catch (e) {
      state = state.copyWith(
        greeting: ref.read(homeServiceProvider).getGreeting(),
        userName: 'Traveler',
      );
    }
  }

  Future<void> connectAndFetchCalendar() async {
    // Phase 1 — show "Connecting to Google..."
    state = state.copyWith(
      calendarStatus: CalendarStatus.connecting,
      errorMessage: null,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 2 — show "Analysing your calendar..."
    state = state.copyWith(calendarStatus: CalendarStatus.fetchingTrips);

    final result = await ref.read(calendarServiceProvider).connectAndFetchTrip();

    if (result is CalendarSuccess) {
      // Write the calendar trip into selectedTripProvider so the Alert Screen
      // uses real calendar data instead of mock data.
      ref.read(selectedTripProvider.notifier).setTrip(result.trip);

      state = state.copyWith(
        calendarStatus: CalendarStatus.connected,
        fetchedTrip: result.trip,
      );
    } else if (result is CalendarFailure) {
      state = state.copyWith(
        calendarStatus: CalendarStatus.error,
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
