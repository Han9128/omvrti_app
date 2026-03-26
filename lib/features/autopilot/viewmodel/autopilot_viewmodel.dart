import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/features/autopilot/model/trip_model.dart';
import 'package:omvrti_app/features/autopilot/service/autopilot_service.dart';

// the provider is just used to create an instance of the service and return that to the provider asking for data
final autoPilotServiceProvider = Provider<AutopilotService>((ref) {
  return AutopilotService();
});

// this is FutureProvider which takes the object created in Provider, fetch and return the data
final tripProvider = FutureProvider<TripModel>((ref) async {
  final service = ref.watch(autoPilotServiceProvider);
  return await service.fetchTrip();
});
