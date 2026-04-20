import 'package:omvrti_app/features/autopilot/model/flight_model.dart';

class FlightService {
  Future<FlightModel> fetchFlight() async {
    await Future.delayed(const Duration(seconds: 1));

    return const FlightModel(
      airline: 'United',
      departFlightNumber: 'UA 435',
      returnFlightNumber: 'UA 1558',
      departTime: '8:30 AM',
      departArrival: '4:55 PM',
      returnTime: '8:10 PM',
      returnArrival: '11:55 PM',
      departAirport: 'SFO',
      arrivalAirport: 'JFK',
      flightClass: 'Economy',
      stops: 'Nonstop',
      departDuration: '5h 25m',
      returnDuration: '6h 45m',
      price: 515.0,
      rewardsAmount: 10.0,
    );
  }
}
