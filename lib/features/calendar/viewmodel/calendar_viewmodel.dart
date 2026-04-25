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

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/autopilot_viewmodel.dart';
import 'package:omvrti_app/features/calendar/model/calendar_event_model.dart';
import 'package:omvrti_app/features/calendar/model/calendar_vendor_model.dart';
import 'package:omvrti_app/features/calendar/model/sub_calendar_model.dart';
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
  final String? connectedEmail;

  const GoogleConnectionState({
    this.status = GoogleConnectionStatus.idle,
    this.errorMessage,
    this.connectedEmail,
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
      state = GoogleConnectionState(
        status: GoogleConnectionStatus.success,
        connectedEmail: result.connectedEmail,
      );
    } else if (result is oauth.CalendarFailure) {
      state = GoogleConnectionState(
        status: GoogleConnectionStatus.error,
        errorMessage: result.message,
      );
    }
  }

  void reset() => state = const GoogleConnectionState();

  Future<void> disconnect() async {
    final service = ref.read(_oauthServiceProvider);
    await service.signOut();
    state = const GoogleConnectionState();
  }
}

final googleCalendarConnectionProvider =
    NotifierProvider<GoogleCalendarConnectionNotifier, GoogleConnectionState>(
  GoogleCalendarConnectionNotifier.new,
);

// ── Sync Settings ──────────────────────────────────────────────────────────────

class CalendarSyncSettings {
  final bool autoSync;
  final bool twoWaySync;

  const CalendarSyncSettings({this.autoSync = true, this.twoWaySync = true});

  CalendarSyncSettings copyWith({bool? autoSync, bool? twoWaySync}) =>
      CalendarSyncSettings(
        autoSync: autoSync ?? this.autoSync,
        twoWaySync: twoWaySync ?? this.twoWaySync,
      );
}

class CalendarSyncSettingsNotifier extends Notifier<CalendarSyncSettings> {
  @override
  CalendarSyncSettings build() => const CalendarSyncSettings();

  void setAutoSync(bool value) => state = state.copyWith(autoSync: value);
  void setTwoWaySync(bool value) => state = state.copyWith(twoWaySync: value);
}

final calendarSyncSettingsProvider =
    NotifierProvider<CalendarSyncSettingsNotifier, CalendarSyncSettings>(
  CalendarSyncSettingsNotifier.new,
);

// ── Sub-calendar list ──────────────────────────────────────────────────────────

class SubCalendarListNotifier extends AsyncNotifier<List<SubCalendarModel>> {
  @override
  Future<List<SubCalendarModel>> build() async {
    ref.keepAlive(); // prevent dispose between navigations — fetch only once
    return ref.read(calendarServiceProvider).fetchConnections();
  }

  Future<void> toggleSync(int calendarId) async {
    final current = state.value;
    if (current == null) return;

    final cal = current.firstWhere((c) => c.id == calendarId);
    final newSyncOn = !cal.isSyncOn;

    // Optimistic update
    state = AsyncData(
      current.map((c) => c.id == calendarId ? c.copyWith(isSyncOn: newSyncOn) : c).toList(),
    );

    try {
      await ref.read(calendarServiceProvider).toggleCalendarSync(calendarId, syncOn: newSyncOn);
    } catch (e) {
      // Revert on failure
      debugPrint('🔴 [CalendarVM] toggleSync failed, reverting: $e');
      state = AsyncData(
        (state.value ?? current)
            .map((c) => c.id == calendarId ? c.copyWith(isSyncOn: !newSyncOn) : c)
            .toList(),
      );
    }
  }
}

final subCalendarListProvider =
    AsyncNotifierProvider<SubCalendarListNotifier, List<SubCalendarModel>>(
  SubCalendarListNotifier.new,
);

// ── Calendar events for the primary calendar ───────────────────────────────────

final calendarEventsProvider =
    FutureProvider<List<CalendarEventModel>>((ref) async {
  final calendars = await ref.watch(subCalendarListProvider.future);
  final primary = calendars.firstWhere(
    (c) => c.isPrimary,
    orElse: () => calendars.first,
  );
  debugPrint('🔵 [calendarEventsProvider] fetching events for ${primary.syncCalendarId}');
  return ref.read(calendarServiceProvider).fetchCalendarEvents(primary.syncCalendarId);
});