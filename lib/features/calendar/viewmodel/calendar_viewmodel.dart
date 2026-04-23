// ─────────────────────────────────────────────────────────────────────────────
// calendar_viewmodel.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// Two providers — same MVVM pattern used across the whole app:
//
//   calendarServiceProvider → singleton CalendarService instance
//   calendarVendorsProvider → FutureProvider<List<CalendarVendor>>
//
// WHY FutureProvider (not StateNotifier)?
//   This screen is READ-ONLY — it fetches vendors and displays them.
//   The user taps a vendor to connect, but that navigation action doesn't
//   mutate the vendor list. FutureProvider is the correct, simpler choice.
//
// The UI watches calendarVendorsProvider and uses .when() to handle:
//   loading → show shimmer / spinner
//   error   → show retry button
//   data    → render the vendor list

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/autopilot_viewmodel.dart';
import 'package:omvrti_app/features/calendar/model/calendar_vendor_model.dart';
import 'package:omvrti_app/features/calendar/service/calendar_service.dart';
import 'package:omvrti_app/features/home/service/calendar_service.dart' as oauth;

// ── Vendor list providers ──────────────────────────────────────────────────────

final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService();
});

final calendarVendorsProvider =
    FutureProvider<List<CalendarVendor>>((ref) async {
  final service = ref.watch(calendarServiceProvider);
  return await service.fetchVendors();
});

// ── Google Calendar OAuth connection ──────────────────────────────────────────

enum GoogleConnectionStatus { idle, connecting, success, error }

class GoogleConnectionState {
  final GoogleConnectionStatus status;
  final String? errorMessage;

  const GoogleConnectionState({
    this.status = GoogleConnectionStatus.idle,
    this.errorMessage,
  });

  bool get isConnecting => status == GoogleConnectionStatus.connecting;
  bool get isSuccess => status == GoogleConnectionStatus.success;
  bool get isError => status == GoogleConnectionStatus.error;
}

final _oauthServiceProvider = Provider<oauth.CalendarService>((ref) {
  return oauth.CalendarService();
});

class GoogleCalendarConnectionNotifier
    extends Notifier<GoogleConnectionState> {
  @override
  GoogleConnectionState build() => const GoogleConnectionState();

  Future<void> connect() async {
    if (state.isConnecting) return;
    state = const GoogleConnectionState(
      status: GoogleConnectionStatus.connecting,
    );

    final service = ref.read(_oauthServiceProvider);
    final result = await service.connectAndFetchTrip();

    if (result is oauth.CalendarSuccess) {
      ref.read(selectedTripProvider.notifier).setTrip(result.trip);
      state = const GoogleConnectionState(status: GoogleConnectionStatus.success);
    } else if (result is oauth.CalendarFailure) {
      state = GoogleConnectionState(
        status: GoogleConnectionStatus.error,
        errorMessage: result.message,
      );
    }
  }

  void reset() => state = const GoogleConnectionState();
}

final googleCalendarConnectionProvider =
    NotifierProvider<GoogleCalendarConnectionNotifier, GoogleConnectionState>(
  GoogleCalendarConnectionNotifier.new,
);