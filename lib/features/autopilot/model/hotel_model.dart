// ─────────────────────────────────────────────────────────────────────────────
// HotelModel
// ─────────────────────────────────────────────────────────────────────────────
//
// Represents all hotel data displayed on the AutoPilot Hotel Screen.
//
// Design-to-field mapping (from the hotel screen screenshot):
//
//   "Stay at New York"                → destinationCity
//   "Residence Inn Mariott"           → hotelName
//   "New York Downtown"               → hotelArea
//   "Manhattan/WTC Area"              → hotelSubArea
//   "$275"                            → pricePerNight
//   "$10 OmVrti Rewards"              → rewardsAmount
//   "Check in – Tue, Jun 1, 2026"     → checkInDate  (DateTime)
//   "12 PM"                           → checkInTime  (String)
//   "Check Out – Fri, Jun 5, 2026"    → checkOutDate (DateTime)
//   "11 AM"                           → checkOutTime (String)
//   "Free Parking"                    → amenities    (List<HotelAmenity>)
//   "Buffet Breakfast Included"       → amenities
//   "Rated 4-Star"                    → starRating   (int)
//   "10 mins walk to downtown"        → walkTime
//   Hotel photo                       → imageAsset   (local) or imageUrl (network)
//
// Why DateTime for dates instead of String?
//   → Same pattern as TripModel. DateTime gives us flexibility to format
//     the date any way we want using our Formatters utility, and makes
//     date math easy (e.g. number of nights = checkOut - checkIn).

class HotelModel {
  // ── Identity ───────────────────────────────────────────────────────────────

  /// City name shown as the section title: "Stay at New York"
  final String destinationCity;

  /// Full hotel name: "Residence Inn Mariott"
  final String hotelName;

  /// Neighbourhood/area: "New York Downtown"
  final String hotelArea;

  /// Sub-area or landmark: "Manhattan/WTC Area"
  final String hotelSubArea;

  // ── Image ──────────────────────────────────────────────────────────────────

  /// Local asset path for the hotel hero image shown in the card.
  /// e.g. "assets/images/hotel_ny.jpg"
  /// When real API is integrated, swap this to a `imageUrl` String for network images.
  final String imageAsset;

  // ── Pricing ────────────────────────────────────────────────────────────────

  /// Price per night in USD: 275.0
  final double pricePerNight;

  /// OmVrti reward points in USD that this booking earns: 10.0
  final double rewardsAmount;

  // ── Dates & Times ──────────────────────────────────────────────────────────

  /// Check-in date. Will be formatted using Formatters.formatDate()
  final DateTime checkInDate;

  /// Check-in time as a display string: "12 PM"
  /// Kept as String because it comes from the API as formatted text.
  final String checkInTime;

  /// Check-out date. Will be formatted using Formatters.formatDate()
  final DateTime checkOutDate;

  /// Check-out time as a display string: "11 AM"
  final String checkOutTime;

  // ── Amenities ──────────────────────────────────────────────────────────────

  /// List of amenity items shown below the date rows.
  /// Each amenity has an icon path + label text.
  /// Using a List makes it easy to add/remove amenities from API without
  /// changing the UI — the UI just maps over the list.
  final List<HotelAmenity> amenities;

  // ── Rating & Walk ──────────────────────────────────────────────────────────

  /// Star rating of the hotel: 4 → "Rated 4-Star"
  final int starRating;

  /// Walking time to city centre: "10 mins walk to downtown"
  final String walkTime;

  const HotelModel({
    required this.destinationCity,
    required this.hotelName,
    required this.hotelArea,
    required this.hotelSubArea,
    required this.imageAsset,
    required this.pricePerNight,
    required this.rewardsAmount,
    required this.checkInDate,
    required this.checkInTime,
    required this.checkOutDate,
    required this.checkOutTime,
    required this.amenities,
    required this.starRating,
    required this.walkTime,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// HotelAmenity
// ─────────────────────────────────────────────────────────────────────────────
//
// A small data class representing one amenity row:
//   [icon]  label text
//
// Why a separate class instead of a Map<String, String>?
//   → Type safety. With a Map you can accidentally pass the wrong key.
//     A class with named fields makes mistakes impossible at compile time.
//
// Example:
//   HotelAmenity(iconAsset: AppIcons.calendar, label: 'Check in')
//   HotelAmenity(iconAsset: AppIcons.parking,  label: 'Free Parking')

class HotelAmenity {
  /// SVG icon asset path from AppIcons constants
  final String iconAsset;

  /// Display label: "Free Parking", "Buffet Breakfast Included", etc.
  final String label;

  const HotelAmenity({
    required this.iconAsset,
    required this.label,
  });
}