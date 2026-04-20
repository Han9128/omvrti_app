import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/features/autopilot/model/flight_model.dart';
import 'package:omvrti_app/features/autopilot/service/flight_service.dart';

final flightServiceProvider = Provider<FlightService>((ref) => FlightService());

final flightProvider = FutureProvider<FlightModel>((ref) async {
  return ref.watch(flightServiceProvider).fetchFlight();
});
