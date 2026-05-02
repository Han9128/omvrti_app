// ─────────────────────────────────────────────────────────────────────────────
// Calendar Vendor Models
// ─────────────────────────────────────────────────────────────────────────────
//
// Two classes here:
//
//   CalendarVendor      → one vendor from the "data" array in the API response
//   CalendarApiResponse → the full API response wrapper
//
// WHY a separate wrapper class?
//   The API doesn't return a bare list — it returns:
//     { "success": true, "data": [...], "errors": null, "code": "SUCCESS" }
//
//   We parse the outer envelope first (CalendarApiResponse), then extract
//   the inner list. This way if the API adds more envelope fields later
//   (e.g. pagination), we only update CalendarApiResponse — not the screen.
//
// JSON → Model mapping:
//   {
//     "id": 1,
//     "name": "google",            → used to load asset: google_calendar.png
//     "displayName": "Google Calendar", → shown as the row label
//     "vendorType": "1",
//     "isNewConnection": true,     → could show a "New" badge in future
//     "authType": "1"
//   }

class CalendarVendor {
  /// Unique vendor ID from the backend
  final int id;

  /// Short name used to resolve the icon asset.
  /// e.g. "google" → "assets/images/calendar/google_calendar.png"
  final String name;

  /// Full display label shown in the UI row.
  /// e.g. "Google Calendar", "Apple Calendar"
  final String displayName;

  /// Vendor category type — reserved for future filtering
  final String vendorType;

  /// Whether this is a new integration option — reserved for "New" badge
  final bool isNewConnection;

  /// Authentication type — "1" = OAuth, could expand to other types
  final String authType;

  /// Whether this vendor is already connected to the user's account
  final bool isConnected;

  const CalendarVendor({
    required this.id,
    required this.name,
    required this.displayName,
    required this.vendorType,
    required this.isNewConnection,
    required this.authType,
    this.isConnected = false,
  });

  // ── fromJson factory constructor ────────────────────────────────────────────
  //
  // CONCEPT: factory constructor
  //   A factory constructor is used when you don't always return a NEW instance.
  //   It's the standard Dart pattern for JSON parsing.
  //   `json` is a Map<String, dynamic> — the parsed JSON object for one vendor.
  //
  // The ?? operator provides a fallback if a field is missing from the JSON.
  // This prevents a crash if the API ever sends an incomplete object.

  factory CalendarVendor.fromJson(Map<String, dynamic> json) {
    return CalendarVendor(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      vendorType: json['vendorType'] as String? ?? '',
      // JSON booleans come through as bool in Dart's json.decode
      isNewConnection: json['isNewConnection'] as bool? ?? false,
      authType: json['authType'] as String? ?? '',
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  // ── Computed property: asset path ───────────────────────────────────────────
  //
  // Derives the PNG asset path from the vendor name.
  // Convention: assets/images/calendar/{name}_calendar.png
  //
  // Examples:
  //   name = "google"      → assets/images/calendar/google_calendar.png
  //   name = "apple"       → assets/images/calendar/apple_calendar.png
  //   name = "outlook"     → assets/images/calendar/outlook_calendar.png
  //
  // Using a getter (computed property) instead of storing it as a field
  // keeps the model lean — the path is always derivable from `name`.

  String get iconAssetPath =>
      'assets/images/calendar/${name}_calendar.png';
}

// ─────────────────────────────────────────────────────────────────────────────
// CalendarApiResponse — full API envelope
// ─────────────────────────────────────────────────────────────────────────────
//
// Mirrors the outer structure of the API response:
//   {
//     "success": true,
//     "data": [ ... ],
//     "errors": null,
//     "code": "SUCCESS",
//     "message": "Request completed successfully"
//   }

class CalendarApiResponse {
  final bool success;
  final List<CalendarVendor> data;
  final String? errors;
  final String code;
  final String message;

  const CalendarApiResponse({
    required this.success,
    required this.data,
    this.errors,
    required this.code,
    required this.message,
  });

  factory CalendarApiResponse.fromJson(Map<String, dynamic> json) {
    // Parse the "data" array into a list of CalendarVendor objects.
    // json['data'] is a List<dynamic> — we cast and map each element.
    final List<dynamic> rawData = json['data'] as List<dynamic>? ?? [];
    final vendors = rawData
        .map((item) => CalendarVendor.fromJson(item as Map<String, dynamic>))
        .toList();

    return CalendarApiResponse(
      success: json['success'] as bool? ?? false,
      data: vendors,
      errors: json['errors'] as String?,
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}