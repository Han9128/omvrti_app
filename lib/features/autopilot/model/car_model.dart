// ─────────────────────────────────────────────────────────────────────────────
// CarModel
// ─────────────────────────────────────────────────────────────────────────────
//
// Represents all car rental data displayed on the AutoPilot Car Screen.
//
// Design-to-field mapping (from the car rental screen screenshot):
//
//   "Car Rental"                   → section header (hardcoded in UI)
//   "HertZ"                        → rentalCompany
//   "Standard 2/4 Door"            → carCategory
//   "Kia K5 or Similar"            → carModel
//   car photo                      → imageAsset
//   "$65"                          → pricePerDay
//   "$5 OmVrti Rewards"            → rewardsAmount
//   "Transmission: Automatic"      → specs → CarSpec
//   "Seats: 5"                     → specs → CarSpec
//   "Fits 3 Luggage"               → specs → CarSpec
//   "2WD"                          → specs → CarSpec
//   "28 MPG"                       → specs → CarSpec
//
// WHY a List<CarSpec> for specs?
//   → Same reasoning as HotelAmenity — data-driven UI. The API can add/
//     remove specs without any UI changes. The screen just maps over the list.

class CarModel {
  // ── Rental Company ─────────────────────────────────────────────────────────

  /// Rental company name: "HertZ"
  final String rentalCompany;

  // ── Car Details ────────────────────────────────────────────────────────────

  /// Category of car: "Standard 2/4 Door"
  final String carCategory;

  /// Specific model or variant: "Kia K5 or Similar"
  final String carModel;

  /// Local asset path for the car image.
  /// e.g. "assets/images/car_hertz.png"
  final String imageAsset;

  // ── Pricing ────────────────────────────────────────────────────────────────

  /// Rental price per day in USD: 65.0
  final double pricePerDay;

  /// OmVrti rewards earned from this booking in USD: 5.0
  final double rewardsAmount;

  // ── Specs ──────────────────────────────────────────────────────────────────

  /// List of car spec rows shown below the divider.
  /// Each spec has an SVG icon + label text.
  /// ORDER matters — matches the design top-to-bottom.
  final List<CarSpec> specs;

  const CarModel({
    required this.rentalCompany,
    required this.carCategory,
    required this.carModel,
    required this.imageAsset,
    required this.pricePerDay,
    required this.rewardsAmount,
    required this.specs,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CarSpec
// ─────────────────────────────────────────────────────────────────────────────
//
// A single spec row: [icon]  label
//
// Examples:
//   CarSpec(iconAsset: AppIcons.transmission, label: 'Transmission: Automatic')
//   CarSpec(iconAsset: AppIcons.seats,        label: 'Seats: 5')
//   CarSpec(iconAsset: AppIcons.luggage,      label: 'Fits 3 Luggage')

class CarSpec {
  /// SVG icon asset path from AppIcons constants
  final String iconAsset;

  /// Display text: "Transmission: Automatic", "Seats: 5", etc.
  final String label;

  const CarSpec({
    required this.iconAsset,
    required this.label,
  });
}