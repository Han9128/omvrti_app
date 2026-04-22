// ─────────────────────────────────────────────────────────────────────────────
// HotelService
// ─────────────────────────────────────────────────────────────────────────────
//
// Responsible ONLY for fetching hotel data.
// Currently uses mock data — replace the body of fetchHotel() with a real
// HTTP call when the API is ready. Nothing else in the app needs to change.
//
// Pattern followed: same as AutopilotService.fetchTrip()
//   → async method, simulated delay, returns a model object.

import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/features/autopilot/model/hotel_model.dart';

class HotelService {
  /// Fetches hotel data for the auto-pilot booking flow.
  ///
  /// [Future] tells Dart: "this will give you a value later, not right now."
  /// The caller (provider) awaits this and handles loading/error states.
  Future<HotelModel> fetchHotel({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required String destinationCity,
  }) async {
    // Simulate a network request delay (2 seconds).
    // Remove this line when connecting to a real API.
    await Future.delayed(const Duration(seconds: 2));

    // ── MOCK DATA ────────────────────────────────────────────────────────────
    // Every field maps directly to a UI element on the hotel screen.
    // Replace this return statement with an HTTP GET + JSON parsing
    // when the backend is ready.
    return HotelModel(
      destinationCity: destinationCity,
      hotelName: 'Residence Inn Marriott',
      hotelArea: '$destinationCity Downtown',
      hotelSubArea: 'Manhattan/WTC Area',

      // Local asset — swap to imageUrl: 'https://...' for network images
      imageAsset: AppImages.hotel, // add this key to AppImages constants

      pricePerNight: 275.0,
      rewardsAmount: 10.0,

      checkInDate: checkInDate,
      checkInTime: '12 PM',

      checkOutDate: checkOutDate,
      checkOutTime: '11 AM',

      // Amenity list — each entry renders as one icon + label row.
      // ORDER matters: matches the design top-to-bottom.
      amenities: const [
        HotelAmenity(
          iconAsset: AppIcons.parking, // 🅿 icon
          label: 'Free Parking',
        ),
        HotelAmenity(
          iconAsset: AppIcons.breakfast, // 🍳 icon
          label: 'Buffet Breakfast Included',
        ),
      ],

      starRating: 4,
      walkTime: '10 mins walk to downtown',
    );
  }
}