import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/features/autopilot/model/trip_model.dart';
import 'package:omvrti_app/features/autopilot/service/autopilot_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELECTED TRIP PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
//
// Bridge between Home Screen (calendar import) and AutoPilot Alert Screen.
// Home ViewModel writes the fetched trip here; Alert Screen reads from here.
//
// StateProvider was removed in Riverpod 3.x — replaced with NotifierProvider.

final selectedTripProvider =
    NotifierProvider<SelectedTripNotifier, TripModel?>(SelectedTripNotifier.new);

class SelectedTripNotifier extends Notifier<TripModel?> {
  @override
  TripModel? build() => null;

  void setTrip(TripModel? trip) => state = trip;
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE PROVIDER
// ─────────────────────────────────────────────────────────────────────────────

final autoPilotServiceProvider = Provider<AutopilotService>((ref) {
  return AutopilotService();
});

// ─────────────────────────────────────────────────────────────────────────────
// TRIP PROVIDER
// ─────────────────────────────────────────────────────────────────────────────
//
// Priority logic:
//   1. If selectedTripProvider has a trip → use it (came from calendar)
//   2. If null → fall back to AutopilotService mock (direct navigation / dev)

final tripProvider = FutureProvider<TripModel>((ref) async {
  final selectedTrip = ref.watch(selectedTripProvider);

  if (selectedTrip != null) {
    return selectedTrip;
  }

  final service = ref.watch(autoPilotServiceProvider);
  return service.fetchTrip();
});
