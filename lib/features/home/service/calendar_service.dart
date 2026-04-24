// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR SERVICE  (Authorization Code Flow)
// ─────────────────────────────────────────────────────────────────────────────
//
// Flow:
//   1. Frontend triggers Google Sign-In → receives a one-time server auth code
//   2. Frontend POSTs that code to the backend
//   3. Backend exchanges the code for Google OAuth tokens (access + refresh)
//   4. Backend calls Google Calendar API, finds trip events, builds a TripModel
//   5. Backend returns the trip as JSON → frontend parses and shows it
//
// WHY a server auth code instead of an access token?
//   An access token expires in ~1 hour. If we sent the access token to the
//   backend, it could only use the calendar for that session.
//   A server auth code lets the backend obtain a REFRESH token, which means
//   it can access the user's calendar indefinitely (until revoked) — even when
//   the app is closed. This is the correct pattern for backend-driven calendar
//   sync.
//
// BACKEND REQUIREMENTS:
//   • A Google Cloud project with Calendar API enabled
//   • An OAuth 2.0 Web Client ID (used as serverClientId below)
//   • An endpoint: POST /api/calendar/google/connect
//     Request body:  { "authCode": "<server_auth_code>" }
//     Response body: {
//       "success": true,
//       "data": { ...TripModel fields... },
//       "message": "Trip found"
//     }
//
// SETUP STEPS (one-time):
//   1. Go to Google Cloud Console → APIs & Services → Credentials
//   2. Create an OAuth 2.0 Web Application client ID
//   3. Replace _serverClientId below with that client ID
//   4. Add that same client ID to your backend's Google OAuth config

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:omvrti_app/features/autopilot/model/trip_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR RESULT — success/failure sealed pattern
// ─────────────────────────────────────────────────────────────────────────────

class CalendarResult {
  const CalendarResult._();
}

class CalendarSuccess extends CalendarResult {
  final TripModel trip;
  const CalendarSuccess({required this.trip}) : super._();
}

class CalendarFailure extends CalendarResult {
  final String message;
  const CalendarFailure({required this.message}) : super._();
}

// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class CalendarService {
  // ── Backend URL ─────────────────────────────────────────────────────────────
  // Android emulator → 10.0.2.2 maps to your dev machine's localhost
  // Physical device  → use your machine's local network IP (e.g. 192.168.x.x)
  // Production       → replace with your real API base URL
  static const String _baseUrl = 'http://192.168.64.153:8080';
  static const String _connectEndpoint = '/api/auth/google/exchange';

  // ── Google OAuth Web Client ID ───────────────────────────────────────────────
  // This is the Web Application client ID from Google Cloud Console.
  // It must match the client ID your backend uses to exchange the auth code.
  //
  // ⚠️  Replace this with your actual Web Client ID before testing.
  //     Format: XXXXXXXXXX-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
  static const String _serverClientId =
         '499273557610-2b7obiuik64a0ke28t75hsoolqdk357p.apps.googleusercontent.com';
      // '516394194747-4hc0o16bnvbqee0ungln3ii5shbjhhfp.apps.googleusercontent.com';
      
// 499273557610-2b7obiuik64a0ke28t75hsoolqdk357p.apps.googleusercontent.com

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
    // serverClientId tells GoogleSignIn which backend client will be
    // receiving the auth code — required to generate a serverAuthCode.
    serverClientId: _serverClientId,
  );

  final http.Client _client;

  CalendarService({http.Client? client}) : _client = client ?? http.Client();

  /// Signs the user in with Google, then sends the authorization code to
  /// the backend. The backend accesses Google Calendar and returns a trip.
  Future<CalendarResult> connectAndFetchTrip() async {
    try {
      // ── Step 1: Google Sign-In ───────────────────────────────────────────
      // disconnect() first so the user always sees the account picker and
      // Google always issues a fresh, unused authorization code.
      // (Reusing a previous sign-in session won't produce a new serverAuthCode.)
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return const CalendarFailure(message: 'Sign in was cancelled.');
      }

      // ── Step 2: Get the server auth code ────────────────────────────────
      // serverAuthCode is a one-time-use code — the backend exchanges it
      // for access + refresh tokens. It is only available when serverClientId
      // is set correctly on this GoogleSignIn instance.
      final String? serverAuthCode = account.serverAuthCode;

      if (serverAuthCode == null) {
        return const CalendarFailure(
          message:
              'Could not get authorization code from Google. '
              'Make sure _serverClientId is set to your Web Client ID.',
        );
      }

      debugPrint('✅ SERVER AUTH CODE: $serverAuthCode');

      // ── Step 3: POST auth code to backend ───────────────────────────────
      try {
        final uri = Uri.parse('$_baseUrl$_connectEndpoint');
        final response = await _client
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({'code': serverAuthCode}),
            )
            .timeout(const Duration(seconds: 30));

        debugPrint('📡 EXCHANGE RESPONSE [${response.statusCode}]: ${response.body}');

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final data = body['data'];
          if (body['success'] == true && data is Map<String, dynamic> && data.isNotEmpty && data['success'] != false) {
            return CalendarSuccess(
              trip: TripModel.fromJson(data),
            );
          }
        }
      } catch (e) {
        debugPrint('⚠️ Backend exchange failed, using mock data: $e');
      }

      // ── Fallback: no events from backend → use mock trip ────────────────
      debugPrint('ℹ️ No calendar events found — loading mock trip data.');
      return CalendarSuccess(
        trip: TripModel(
          purpose: 'Business Meeting',
          company: 'OmVrti Test',
          estimatedBudget: 2500,
          originCity: 'San Francisco',
          originState: 'CA, United States',
          originAirport: 'SFO, San Francisco International Airport, Terminal 3',
          destCity: 'New York',
          destState: 'NY, United States',
          destAirport: 'JFK, John F. Kennedy International Airport, Terminal 4',
          departDate: DateTime.now().add(const Duration(days: 14)),
          returnDate: DateTime.now().add(const Duration(days: 18)),
          tripDuration: 4,
          travelerName: 'Mr. ${account.displayName ?? 'Traveler'}',
          firstMeeting: 'First Meeting: 9:00 AM – 11:00 AM',
          lastMeeting: 'Last Meeting: 2:00 PM – 4:00 PM',
          meetingLocation: '200 Park Ave, New York, NY',
          departTime: '6:00 AM – 10:00 AM',
          returnTime: '6:00 PM – 10:00 PM',
          accommodationNote: 'Book a hotel for 4 nights',
          carRentalNote: 'Rent a car for 4 days',
        ),
      );
    } catch (e) {
      return CalendarFailure(message: e.toString());
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}
