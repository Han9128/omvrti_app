class TripModel {
  final String purpose;
  final String company;
  final double estimatedBudget;

  // origin
  final String originCity;
  final String originState;
  final String originAirport;

  // destination
  final String destCity;
  final String destState;
  final String destAirport;

  // dates
  final DateTime departDate;
  final DateTime returnDate;
  final int tripDuration;

  // traveller
  final String travelerName;

  const TripModel({
    required this.purpose,
    required this.company,
    required this.estimatedBudget,
    required this.originCity,
    required this.originState,
    required this.originAirport,
    required this.destCity,
    required this.destState,
    required this.destAirport,
    required this.departDate,
    required this.returnDate,
    required this.tripDuration,
    required this.travelerName,
  });
}
