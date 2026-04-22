import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/features/autopilot/model/summary_model.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/autopilot_viewmodel.dart';

// tripProvider handles the calendar-vs-manual priority:
//   - selectedTripProvider has a trip → uses calendar/manual form data
//   - Otherwise falls back to AutopilotService mock
final summaryProvider = FutureProvider<SummaryModel>((ref) async {
  final trip = await ref.watch(tripProvider.future);

  return SummaryModel(
    // ── From real trip data ──────────────────────────────────────────────────
    purpose: trip.purpose,
    company: trip.company,
    originCity: trip.originCity,
    originState: trip.originState,
    destCity: trip.destCity,
    destState: trip.destState,
    departDate: trip.departDate,
    returnDate: trip.returnDate,
    tripDuration: trip.tripDuration,

    // ── Hardcoded until pricing algorithm is available ───────────────────────
    tripCost: 1875,
    estimatedSpend: 2500,
    directSavings: 375,
    directSavingsPct: 15,
    overheadSavings: 250,
    overheadSavingsPct: 10,
    totalCompanySavings: 625,
    totalSavingsPct: 25,
    rewardsEarned: 75,
    hotelName: 'Residence Inn Marriott, New York Downtown',
    carRentalName: 'Hertz  –  Standard 2/4 Door',
  );
});
