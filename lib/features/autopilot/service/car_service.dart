// ─────────────────────────────────────────────────────────────────────────────
// CarService
// ─────────────────────────────────────────────────────────────────────────────
//
// Responsible ONLY for fetching car rental data.
// Mock data for now — replace fetchCar() body with a real HTTP call
// when the API is ready. The ViewModel and UI don't need to change at all.
//
// Pattern: identical to AutopilotService and HotelService.

import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/features/autopilot/model/car_model.dart';

class CarService {
  /// Fetches car rental data for the auto-pilot booking flow.
  Future<CarModel> fetchCar() async {
    // Simulate network latency — remove when connecting to a real API.
    await Future.delayed(const Duration(seconds: 2));

    // ── MOCK DATA ────────────────────────────────────────────────────────────
    // Every field maps to a UI element on the car screen.
    return CarModel(
      rentalCompany: 'HertZ',
      carCategory: 'Standard 2/4 Door',
      carModel: 'Kia K5 or Similar',

      // Local asset — swap to imageUrl when backend provides a URL
      imageAsset: AppImages.car_hertz, // add this key to AppImages constants

      pricePerDay: 65.0,
      rewardsAmount: 5.0,

      // Specs list — ORDER matches the design (top to bottom).
      // Each CarSpec maps to one icon + label row on screen.
      specs: const [
        CarSpec(
          iconAsset: AppIcons.transmission, // ⚙️ gear/transmission icon
          label: 'Transmission: Automatic',
        ),
        CarSpec(
          iconAsset: AppIcons.seats, // 💺 seat icon
          label: 'Seats: 5',
        ),
        CarSpec(
          iconAsset: AppIcons.luggage, // 🧳 luggage icon
          label: 'Fits 3 Luggage',
        ),
        CarSpec(
          iconAsset: AppIcons.drive, // 🚗 drive/wheel icon
          label: '2WD',
        ),
        CarSpec(
          iconAsset: AppIcons.fuel, // ⛽ fuel/mpg icon
          label: '28 MPG',
        ),
      ],
    );
  }
}