// ─────────────────────────────────────────────────────────────────────────────
// car_viewmodel.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// Two providers — same pattern used across all autopilot screens:
//
//   1. carServiceProvider  → creates ONE singleton instance of CarService.
//   2. carProvider         → FutureProvider<CarModel> that the UI watches.
//
// The UI uses .when() to handle the three AsyncValue states:
//   loading → spinner
//   data    → render car screen
//   error   → show error message

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/features/autopilot/model/car_model.dart';
import 'package:omvrti_app/features/autopilot/service/car_service.dart';

/// Provides a singleton CarService instance across the app.
final carServiceProvider = Provider<CarService>((ref) {
  return CarService();
});

/// Fetches car rental data and exposes AsyncValue<CarModel> to the UI.
///
/// Why FutureProvider (not StateNotifierProvider)?
/// → The car screen only DISPLAYS data — no user edits happen here.
///   FutureProvider is the simplest correct tool for read-only async data.
///
/// The "Confirm Booking" button action will be handled by a separate
/// StateNotifierProvider in the booking confirmation flow (future scope).
final carProvider = FutureProvider<CarModel>((ref) async {
  final service = ref.watch(carServiceProvider);
  return await service.fetchCar();
});