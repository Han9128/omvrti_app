// class TripModel {
//   final String purpose;
//   final String company;
//   final double estimatedBudget;

//   // origin
//   final String originCity;
//   final String originState;
//   final String originAirport;

//   // destination
//   final String destCity;
//   final String destState;
//   final String destAirport;

//   // dates
//   final DateTime departDate;
//   final DateTime returnDate;
//   final int tripDuration;

//   // traveller
//   final String travelerName;

//   const TripModel({
//     required this.purpose,
//     required this.company,
//     required this.estimatedBudget,
//     required this.originCity,
//     required this.originState,
//     required this.originAirport,
//     required this.destCity,
//     required this.destState,
//     required this.destAirport,
//     required this.departDate,
//     required this.returnDate,
//     required this.tripDuration,
//     required this.travelerName,
//   });
// }


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

  // ── New fields from the updated design ───────────────────────────────────

  // Meeting schedule — two time strings shown under "Meeting Schedule"
  // e.g. "First Meeting: 4 PM – 6 PM, Mon, Jun 1, 2026"
  // null means no meeting schedule to show
  final String? firstMeeting;
  final String? lastMeeting;

  // Meeting location shown below the meeting schedule
  // e.g. "200 Hertx, Ave, New York, NY"
  final String? meetingLocation;

  // Depart and return time strings shown below the dates in the route card
  // e.g. "5:00 AM – 10:00 AM"
  final String? departTime;
  final String? returnTime;

  // Accommodation summary shown in the services card
  // e.g. "Book a hotel for 4 nights"
  final String? accommodationNote;

  final String? carRentalNote;

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
    // New optional fields — nullable so existing code doesn't break
    this.firstMeeting,
    this.lastMeeting,
    this.meetingLocation,
    this.departTime,
    this.returnTime,
    this.accommodationNote,
    this.carRentalNote,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      purpose: json['purpose'] as String? ?? 'Business Trip',
      company: json['company'] as String? ?? 'Company',
      estimatedBudget: (json['estimatedBudget'] as num?)?.toDouble() ?? 2500.0,
      originCity: json['originCity'] as String? ?? 'San Francisco',
      originState: json['originState'] as String? ?? 'CA, United States',
      originAirport: json['originAirport'] as String? ?? 'SFO',
      destCity: json['destCity'] as String? ?? 'New York',
      destState: json['destState'] as String? ?? 'NY, United States',
      destAirport: json['destAirport'] as String? ?? 'JFK',
      departDate: DateTime.parse(json['departDate'] as String),
      returnDate: DateTime.parse(json['returnDate'] as String),
      tripDuration: json['tripDuration'] as int? ?? 3,
      travelerName: json['travelerName'] as String? ?? 'Traveler',
      firstMeeting: json['firstMeeting'] as String?,
      lastMeeting: json['lastMeeting'] as String?,
      meetingLocation: json['meetingLocation'] as String?,
      departTime: json['departTime'] as String?,
      returnTime: json['returnTime'] as String?,
      accommodationNote: json['accommodationNote'] as String?,
      carRentalNote: json['carRentalNote'] as String?,
    );
  }
}