// ─────────────────────────────────────────────────────────────────────────────
// hotel_viewmodel.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// Two providers — same pattern as flight_viewmodel.dart:
//
//   1. hotelServiceProvider  → creates ONE instance of HotelService.
//      Why? Riverpod's Provider guarantees a singleton — the same instance
//      is reused across all widgets that read it. No duplicate objects.
//
//   2. hotelProvider → FutureProvider that calls the service and exposes
//      AsyncValue<HotelModel> to the UI.
//
// AsyncValue has three states the UI handles with .when():
//   AsyncValue.loading() → show spinner
//   AsyncValue.data(hotel) → render hotel screen
//   AsyncValue.error(e, st) → show error message

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/features/autopilot/model/hotel_model.dart';
import 'package:omvrti_app/features/autopilot/service/hotel_service.dart';

/// Provides a singleton instance of HotelService.
/// Any provider that needs hotel data reads this first.
final hotelServiceProvider = Provider<HotelService>((ref) {
  return HotelService();
});

/// Fetches hotel data and exposes it as AsyncValue<HotelModel>.
///
/// The UI watches this provider. When the Future completes, Riverpod
/// automatically rebuilds the widget with the new data.
///
/// Why FutureProvider and not StateNotifierProvider?
/// → The hotel screen is READ-ONLY — it just displays data. No user
///   interactions mutate the hotel state. FutureProvider is the
///   correct, simpler choice for read-only async data.
final hotelProvider = FutureProvider<HotelModel>((ref) async {
  // ref.watch ensures this provider re-fetches if hotelServiceProvider changes.
  final service = ref.watch(hotelServiceProvider);
  return await service.fetchHotel();
});