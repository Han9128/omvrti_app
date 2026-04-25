// ─────────────────────────────────────────────────────────────────────────────
// CalendarService — fetches calendar vendor list from the API
// ─────────────────────────────────────────────────────────────────────────────
//
// Makes an HTTP GET request to:
//   GET http://localhost:8080/api/calendar/connections/vendors
//
// Returns: List<CalendarVendor> — parsed from the "data" array in the response
//
// Error handling strategy:
//   → If HTTP status is not 200 → throw a descriptive exception
//   → If JSON parsing fails     → throw a descriptive exception
//   → If success: false         → throw with the API's own message
//
// WHY throw exceptions instead of returning null?
//   The FutureProvider in Riverpod catches exceptions and exposes them as
//   AsyncValue.error — which the UI handles with .when(error: ...).
//   Returning null would force us to add null checks everywhere in the UI.
//   Exceptions give us a clean single error handling path.
//
// PACKAGE NEEDED:
//   Add to pubspec.yaml:
//     http: ^1.2.1
//   Then run: flutter pub get

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:omvrti_app/features/calendar/model/calendar_event_model.dart';
import 'package:omvrti_app/features/calendar/model/calendar_vendor_model.dart';
import 'package:omvrti_app/features/calendar/model/sub_calendar_model.dart';

class CalendarService {
  // ── Base URL ────────────────────────────────────────────────────────────────
  //
  // Using localhost:8080 as specified.
  //
  // ⚠️ ANDROID EMULATOR NOTE:
  //   On Android emulator, "localhost" refers to the emulator itself, NOT
  //   your development machine. Use 10.0.2.2 instead:
  //     static const String _baseUrl = 'http://10.0.2.2:8080';
  //
  // ⚠️ PHYSICAL DEVICE NOTE:
  //   Use your machine's local network IP address:
  //     static const String _baseUrl = 'http://192.168.x.x:8080';
  //
  // For production, replace with your real server URL:
  //   static const String _baseUrl = 'https://api.omvrti.ai';

 

  static const String _baseUrl = 'http://192.168.64.153:8080'; // Android emulator
  // static const String _baseUrl = 'http://localhost:8080'; // iOS simulator / web

  static const String _vendorsEndpoint = '/api/calendar/connections/vendors';
  static const String _connectionsEndpoint = '/api/calendar/sync/google/calendars';
  static const String _toggleEndpoint = '/api/calendar/sync/calendars';
  static const String _eventsEndpoint = '/api/calendar/google/events';


  // HTTP client instance.
  // Using a field instead of creating http.get() directly makes this
  // class testable — in tests, you can inject a mock client.
  final http.Client _client;

  // Constructor with optional client injection.
  // Default: creates a real HTTP client.
  // Test: inject a MockClient to simulate responses without network.
  CalendarService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the list of available calendar vendors from the API.
  ///
  /// Returns [List<CalendarVendor>] on success.
  /// Throws [Exception] on HTTP error, JSON error, or API-level failure.
  Future<List<CalendarVendor>> fetchVendors() async {
    // Build the URI from base + endpoint
    final uri = Uri.parse('$_baseUrl$_vendorsEndpoint');

    try {
      // Make the GET request with a 10 second timeout.
      // timeout() throws a TimeoutException if the server doesn't respond.
      // This prevents the loading spinner from showing forever.
      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              // TODO: Add auth header when authentication is implemented
              // 'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception(
              'Request timed out. Please check your connection.',
            ),
          );

      // ── Check HTTP status code ────────────────────────────────────────────
      //
      // 200 = success
      // 4xx = client error (bad request, unauthorized, not found)
      // 5xx = server error
      //
      // response.statusCode gives us the HTTP status as an integer.

      if (response.statusCode != 200) {
        print("❌ HTTP ERROR: ${response.statusCode}"); // Log the error status
        throw Exception(
          'Server returned ${response.statusCode}. '
          'Please try again later.',
        );
      }

      // ── Parse JSON ────────────────────────────────────────────────────────
      //
      // response.body is a String — the raw JSON text.
      // jsonDecode() converts it to a Map<String, dynamic>.
      // We then pass it to our CalendarApiResponse factory constructor.


      final Map<String, dynamic> jsonBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      final apiResponse = CalendarApiResponse.fromJson(jsonBody);

      // ── Check API-level success flag ──────────────────────────────────────
      //
      // Even if HTTP is 200, the API might return success: false.
      // Example: { "success": false, "message": "Unauthorized" }
      // We treat this as an error and throw with the API's own message.

      if (!apiResponse.success) {
        throw Exception(
          apiResponse.message.isNotEmpty
              ? apiResponse.message
              : 'Failed to load calendar vendors.',
        );
      }

      // ── Return the parsed vendor list ─────────────────────────────────────
      return apiResponse.data;

    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  /// GET /api/calendar/connections
  /// Returns the list of sub-calendars for the connected Google account.
  Future<List<SubCalendarModel>> fetchConnections() async {
    debugPrint('🔵 [CalendarService] fetchConnections() — GET $_baseUrl$_connectionsEndpoint');
    final uri = Uri.parse('$_baseUrl$_connectionsEndpoint');

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      debugPrint('🔵 [CalendarService] status: ${response.statusCode}');
      debugPrint('🔵 [CalendarService] raw body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}.');
      }

      final decoded = jsonDecode(response.body);
      debugPrint('🔵 [CalendarService] decoded type: ${decoded.runtimeType}');

      List<dynamic> items;
      if (decoded is List) {
        debugPrint('🔵 [CalendarService] response is raw array, length=${decoded.length}');
        items = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['success'] == false) {
          throw Exception(decoded['message'] ?? 'API returned success=false');
        }
        final data = decoded['data'];
        debugPrint('🔵 [CalendarService] data field type: ${data.runtimeType}');
        if (data is List) {
          items = data;
        } else {
          throw Exception('Unexpected data shape: ${data.runtimeType}');
        }
      } else {
        throw Exception('Unknown response shape: ${decoded.runtimeType}');
      }

      debugPrint('🔵 [CalendarService] parsing ${items.length} item(s)');
      final result = <SubCalendarModel>[];
      for (final item in items) {
        debugPrint('🔵 [CalendarService] item fields: ${(item as Map<String, dynamic>).keys.toList()}');
        try {
          final model = SubCalendarModel.fromJson(item);
          debugPrint('✅ [CalendarService] parsed id=${model.id} label="${model.label}" isSyncOn=${model.isSyncOn}');
          result.add(model);
        } catch (e) {
          debugPrint('🔴 [CalendarService] parse failed for item $item — $e');
        }
      }
      debugPrint('🔵 [CalendarService] returning ${result.length} sub-calendar(s)');
      return result;
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// POST /api/calendar/sync/calendars/{id}/toggle
  /// Body: { "syncOn": true/false }
  /// Throws on failure.
  Future<void> toggleCalendarSync(int id, {required bool syncOn}) async {
    final uri = Uri.parse('$_baseUrl$_toggleEndpoint/$id/toggle');
    debugPrint('🔵 [CalendarService] toggleCalendarSync($id, syncOn=$syncOn) — POST $uri');

    final response = await _client
        .put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'syncOn': syncOn}),
        )
        .timeout(const Duration(seconds: 10));

    debugPrint('🔵 [CalendarService] toggle status: ${response.statusCode} body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Toggle failed: server returned ${response.statusCode}.');
    }
  }

  /// GET /api/calendar/google/events?calendarId={calendarId}
  /// Returns all events for the given calendar.
  Future<List<CalendarEventModel>> fetchCalendarEvents(String calendarId) async {
    final uri = Uri.parse('$_baseUrl$_eventsEndpoint').replace(
      queryParameters: {'calendarId': calendarId},
    );
    debugPrint('🔵 [CalendarService] fetchCalendarEvents — GET $uri');

    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    debugPrint('🔵 [CalendarService] events status: ${response.statusCode}');
    debugPrint('🔵 [CalendarService] events body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Events fetch failed: server returned ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);
    List<dynamic> items;

    if (decoded is List) {
      items = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['success'] == false) {
        throw Exception(decoded['message'] ?? 'API returned success=false');
      }
      final data = decoded['data'];
      if (data is Map<String, dynamic> && data['events'] is List) {
        items = data['events'] as List;
      } else if (data is List) {
        items = data;
      } else {
        throw Exception('Unexpected events data shape: ${data.runtimeType}');
      }
    } else {
      throw Exception('Unknown events response shape');
    }

    debugPrint('🔵 [CalendarService] parsing ${items.length} event(s)');
    return items
        .whereType<Map<String, dynamic>>()
        .map(CalendarEventModel.fromJson)
        .toList();
  }
}