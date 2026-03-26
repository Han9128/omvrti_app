import 'package:omvrti_app/features/autopilot/model/trip_model.dart';

class AutopilotService {
  // future is used where to tell that data will come in future not instantly
  Future<TripModel> fetchTrip() async {
    // simulating network delay
    await Future.delayed(const Duration(seconds: 2));

    // mock data of TripModel, will be replaced by api call once it is available.
    return TripModel(
      purpose: 'Client Meeting',
      company: 'Smart Client Inc.',
      estimatedBudget: 2500,
      originCity: 'San Francisco',
      originState: 'CA, United States',
      originAirport: 'SFO, San Francisco International Airport, Terminal 3',
      destCity: 'New York',
      destState: 'NY, United States',
      destAirport: 'JFK, John F. Kennedy International Airport, Terminal 4',
      departDate: DateTime(2026, 6, 1),
      returnDate: DateTime(2026, 6, 5),
      tripDuration: 5,
      travelerName: 'Mr. Sam Watson',
    );
  }
}
