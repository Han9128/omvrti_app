import 'package:omvrti_app/features/autopilot/model/summary_model.dart';

class SummaryService {
  Future<SummaryModel> fetchSummary() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data matching the design exactly
    return SummaryModel(
      purpose: 'Annual Business Summit',
      company: 'Smart Client Inc.',
      tripCost: 1875,
      estimatedSpend: 2500,
      directSavings: 375,
      directSavingsPct: 15,
      overheadSavings: 250,
      overheadSavingsPct: 10,
      totalCompanySavings: 625,
      totalSavingsPct: 25,
      rewardsEarned: 75,
      originCity: 'San Francisco',
      originState: 'CA, United States',
      destCity: 'New York',
      destState: 'NY, United States',
      departDate: DateTime(2026, 6, 1),
      returnDate: DateTime(2026, 6, 5),
      tripDuration: 5,
      hotelName: 'Residence Inn Marriott, New York Downtown',
      carRentalName: 'Hertz  –  Standard 2/4 Door',
    );
  }
}