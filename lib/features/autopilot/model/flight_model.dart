class FlightModel {
  final String airline;
  final String departFlightNumber;
  final String returnFlightNumber;

  final String departTime;       // "8:30 AM"
  final String departArrival;    // "4:55 PM"
  final String returnTime;       // "8:10 PM"
  final String returnArrival;    // "11:55 PM"

  final String departAirport;    // "SFO"
  final String arrivalAirport;   // "JFK"

  final String flightClass;      // "Economy"
  final String stops;            // "Nonstop"
  final String departDuration;   // "5h 25m"
  final String returnDuration;   // "6h 45m"

  final double price;            // 515.0
  final double rewardsAmount;    // 10.0

  const FlightModel({
    required this.airline,
    required this.departFlightNumber,
    required this.returnFlightNumber,
    required this.departTime,
    required this.departArrival,
    required this.returnTime,
    required this.returnArrival,
    required this.departAirport,
    required this.arrivalAirport,
    required this.flightClass,
    required this.stops,
    required this.departDuration,
    required this.returnDuration,
    required this.price,
    required this.rewardsAmount,
  });
}
