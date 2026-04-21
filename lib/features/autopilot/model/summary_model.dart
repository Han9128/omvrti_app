// SummaryModel holds all the data needed to display the AutoPilot Summary screen.
//
// This model is separate from TripModel because the summary screen
// shows calculated financial data (savings, costs) that comes from
// the booking flow — not just the raw trip details.

class SummaryModel {
  // Purpose + company — shown in the blue header card
  final String purpose;
  final String company;

  // Financial summary — shown in the savings card
  final double tripCost;           // actual cost after savings
  final double estimatedSpend;     // original budget (shown as strikethrough)
  final double directSavings;      // absolute saving amount
  final double directSavingsPct;   // percentage e.g. 15
  final double overheadSavings;    // absolute overhead saving
  final double overheadSavingsPct; // percentage e.g. 10
  final double totalCompanySavings;
  final double totalSavingsPct;

  // Rewards earned
  final double rewardsEarned;

  // Route — shown in the route card
  final String originCity;
  final String originState;
  final String destCity;
  final String destState;
  final DateTime departDate;
  final DateTime returnDate;
  final int tripDuration;

  // Booked services
  final String hotelName;     // e.g. "Residence Inn Marriott, New York Downtown"
  final String carRentalName; // e.g. "Hertz – Standard 2/4 Door"

  const SummaryModel({
    required this.purpose,
    required this.company,
    required this.tripCost,
    required this.estimatedSpend,
    required this.directSavings,
    required this.directSavingsPct,
    required this.overheadSavings,
    required this.overheadSavingsPct,
    required this.totalCompanySavings,
    required this.totalSavingsPct,
    required this.rewardsEarned,
    required this.originCity,
    required this.originState,
    required this.destCity,
    required this.destState,
    required this.departDate,
    required this.returnDate,
    required this.tripDuration,
    required this.hotelName,
    required this.carRentalName,
  });
}