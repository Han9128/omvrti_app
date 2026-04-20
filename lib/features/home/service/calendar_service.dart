import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;
import 'package:omvrti_app/features/autopilot/model/trip_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GOOGLE AUTH HTTP CLIENT
// ─────────────────────────────────────────────────────────────────────────────
//
// The googleapis package needs an authenticated HTTP client to make API calls.
// This class wraps a standard http.Client and automatically attaches the
// Google access token to every request as an Authorization header.
//
// Why do we need this?
// → Google Calendar API requires every request to include:
//   "Authorization: Bearer <access_token>"
// → Instead of manually adding this header everywhere, we create
//   one authenticated client and pass it to the CalendarApi.
//   Every request it makes will automatically include the token.

class _GoogleAuthClient extends http.BaseClient {
  // The authorization headers from Google Sign In
  // Contains: { "Authorization": "Bearer <token>" }
  final Map<String, String> _headers;

  // The underlying HTTP client that actually sends requests
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  // intercept every request and inject the auth headers before sending
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Merge our auth headers with whatever headers the request already has
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR RESULT — success/failure pattern
// ─────────────────────────────────────────────────────────────────────────────
//
// Same pattern as AuthResult — the service returns either
// CalendarSuccess (with a TripModel) or CalendarFailure (with an error message).
// The ViewModel checks which type it received and updates state accordingly.

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
  // GoogleSignIn is the entry point for all Google OAuth operations.
  //
  // scopes defines what permissions we're requesting from the user.
  // We only request readonly calendar access — never ask for more
  // permissions than you need. Users trust you more when you ask for less.
  //
  // calendarReadonly scope lets us:
  //   ✅ Read calendar events
  //   ✅ Read event details (title, dates, location, description)
  //   ❌ Create, edit or delete events (we don't need this)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      gcal.CalendarApi.calendarReadonlyScope,
    ],
  );

  // connectAndFetchTrip() is the main method called by the ViewModel.
  //
  // It does three things in sequence:
  //   1. Sign the user into Google (shows OAuth consent screen)
  //   2. Get an authenticated HTTP client using their token
  //   3. Fetch calendar events and parse the first trip found
  //
  // Returns CalendarSuccess with a TripModel, or CalendarFailure with
  // a human-readable error message.
  Future<CalendarResult> connectAndFetchTrip() async {
    try {
      // ── Step 1: Sign in with Google ─────────────────────────────────────
      //
      // signIn() shows the Google account picker and consent screen.
      // If the user has already signed in before, it may skip the UI
      // and return the cached account directly (silent sign-in).
      //
      // Returns null if the user cancels the sign-in flow.
      await _googleSignIn.disconnect();
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      // User tapped the back button or dismissed the sign-in screen
      if (account == null) {
        return const CalendarFailure(
          message: 'Sign in was cancelled.',
        );
      }

      // ── Step 2: Get authentication headers ──────────────────────────────
      //
      // authentication gives us the access token and id token.
      // authHeaders returns these formatted as HTTP headers:
      //   { "Authorization": "Bearer eyJ..." }
      final GoogleSignInAuthentication auth = await account.authentication;
      final authHeaders = await account.authHeaders;

      // Create our authenticated HTTP client using those headers
      final authenticatedClient = _GoogleAuthClient(authHeaders);

      // ── Step 3: Create Calendar API client and fetch events ─────────────
      //
      // CalendarApi wraps all Google Calendar API endpoints.
      // We pass our authenticated client so every request is authorized.
      final calendarApi = gcal.CalendarApi(authenticatedClient);

      // Fetch events from the user's PRIMARY calendar.
      // 'primary' is a special keyword that means the user's main calendar.
      //
      // Parameters explained:
      //   timeMin → only fetch events from now onwards (no past events)
      //   maxResults → limit to 10 events so we don't fetch too much
      //   singleEvents → expand recurring events into individual instances
      //   orderBy → sort by start time so the soonest event comes first
      final now = DateTime.now();
      final events = await calendarApi.events.list(
        'primary',
        timeMin: now,
        maxResults: 10,
        singleEvents: true,
        orderBy: 'startTime',
      );

      // No events found in the calendar
      if (events.items == null || events.items!.isEmpty) {
        return const CalendarFailure(
          message: 'No upcoming events found in your Google Calendar.',
        );
      }

      // ── Step 4: Find a trip event ────────────────────────────────────────
      //
      // Not every calendar event is a trip — some are meetings, birthdays etc.
      // We look for events that have a location set OR whose title contains
      // travel-related keywords. The first matching event becomes the trip.
      final tripEvent = _findTripEvent(events.items!);

      if (tripEvent == null) {
        return const CalendarFailure(
          message:
              'No travel events found in your calendar. Try adding a trip event with a location.',
        );
      }

      // ── Step 5: Parse the calendar event into a TripModel ────────────────
      final trip = _parseEventToTrip(tripEvent, account.displayName ?? 'Traveler');

      return CalendarSuccess(trip: trip);
    } catch (e) {
      // Catch any unexpected errors — network failure, API errors etc.
      return CalendarFailure(
        message: 'Could not connect to Google Calendar. Please try again.',
      );
    }
  }

  // signOut() disconnects Google Calendar.
  // Called when user wants to disconnect from settings.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  // isSignedIn() checks if the user already connected their calendar.
  // Used on app startup to restore connected state without re-authenticating.
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // silentSignIn() tries to reconnect without showing the consent screen.
  // Used when the app reopens and the user was previously connected.
  // Returns null if silent sign-in is not possible (token expired etc.)
  Future<GoogleSignInAccount?> silentSignIn() async {
    return await _googleSignIn.signInSilently();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  // _findTripEvent() scans a list of calendar events and returns the first
  // one that looks like a travel event.
  //
  // Detection rules (any one match = it's a trip):
  //   1. Event has a location set (most travel events have this)
  //   2. Event title contains travel keywords (flight, trip, travel etc.)
  //   3. Event spans multiple days (overnight trips)
  gcal.Event? _findTripEvent(List<gcal.Event> events) {
    // Keywords that suggest a travel event
    const travelKeywords = [
      'trip', 'travel', 'flight', 'hotel', 'conference',
      'summit', 'meeting', 'visit', 'tour', 'business',
    ];

    for (final event in events) {
      final title = (event.summary ?? '').toLowerCase();
      final hasLocation = event.location != null &&
          event.location!.isNotEmpty;

      // Check if title contains any travel keyword
      final hasTravelKeyword = travelKeywords.any(
        (keyword) => title.contains(keyword),
      );

      // Check if event spans multiple days
      final isMultiDay = _isMultiDayEvent(event);

      // Accept the event if any condition is met
      if (hasLocation || hasTravelKeyword || isMultiDay) {
        return event;
      }
    }

    // No trip event found — return null so the caller can handle it
    return null;
  }

  // _isMultiDayEvent() returns true if an event spans more than one day.
  bool _isMultiDayEvent(gcal.Event event) {
    final start = event.start?.dateTime ?? event.start?.date?.toDateTime();
    final end = event.end?.dateTime ?? event.end?.date?.toDateTime();

    if (start == null || end == null) return false;

    // Difference of more than 1 day = multi-day event
    return end.difference(start).inDays > 1;
  }

  // _parseEventToTrip() converts a Google Calendar Event into a TripModel.
  //
  // This is where we "translate" the raw calendar data into our app's
  // data model. Some fields map directly (dates), others are inferred
  // (origin is assumed to be the user's home city for now), and some
  // are given sensible defaults when not available in the calendar event.
  TripModel _parseEventToTrip(gcal.Event event, String travelerName) {
    // ── Parse dates ────────────────────────────────────────────────────────
    // Google Calendar events can have either dateTime (with time)
    // or date (all-day events, no specific time).
    // We handle both cases with the ?? fallback.
    final departDate = event.start?.dateTime ??
        event.start?.date?.toDateTime() ??
        DateTime.now().add(const Duration(days: 7));

    final returnDate = event.end?.dateTime ??
        event.end?.date?.toDateTime() ??
        departDate.add(const Duration(days: 3));

    // Calculate trip duration in days
    final tripDuration = returnDate.difference(departDate).inDays;

    // ── Parse destination from location ────────────────────────────────────
    // The location field in Google Calendar is a free-text string.
    // Users might write: "New York", "New York, NY", "JFK Airport",
    // "123 Main St, New York, NY 10001" etc.
    // We take whatever they wrote as the destination city.
    final location = event.location ?? 'New York';
    final destCity = _extractCityFromLocation(location);

    // ── Parse purpose from event title ─────────────────────────────────────
    // The event title becomes the trip purpose.
    // e.g. "Business Trip - New York" → purpose: "Business Trip"
    final purpose = _cleanEventTitle(event.summary ?? 'Business Trip');

    // ── Parse company from description ─────────────────────────────────────
    // If the user added a description to their calendar event,
    // we look for a company name in it. Otherwise default to "Company".
    final company = _extractCompany(event.description ?? '');

    // ── Build and return TripModel ─────────────────────────────────────────
    // Fields we can't reliably get from calendar (airports, budget, origin)
    // are given realistic defaults. These can be edited by the user
    // on the Alert Screen before proceeding.
    return TripModel(
      purpose: purpose,
      company: company,
      estimatedBudget: 2500, // default budget — user can edit

      // Origin — assumed to be San Francisco for now.
      // In a real app we'd get this from the user's profile (home city).
      // TODO: Get from user profile when profile screen is built
      originCity: 'San Francisco',
      originState: 'CA, United States',
      originAirport: 'SFO, San Francisco International Airport, Terminal 3',

      // Destination — parsed from calendar event location
      destCity: destCity,
      destState: _extractState(location),
      destAirport: _guessAirport(destCity),

      departDate: departDate,
      returnDate: returnDate,
      tripDuration: tripDuration > 0 ? tripDuration : 3,

      travelerName: 'Mr. $travelerName',

      // Fallback values for fields not available from calendar events.
      // Shown on the Alert Screen so the user can review and edit before booking.
      firstMeeting: 'First Meeting: 9:00 AM – 11:00 AM, ${_formatShortDate(departDate)}',
      lastMeeting: 'Last Meeting: 2:00 PM – 4:00 PM, ${_formatShortDate(departDate)}',
      meetingLocation: location,
      departTime: '6:00 AM – 10:00 AM',
      returnTime: '6:00 PM – 10:00 PM',
      accommodationNote: 'Book a hotel for ${tripDuration > 0 ? tripDuration : 3} nights',
      carRentalNote: 'Rent a car for ${tripDuration > 0 ? tripDuration : 3} days',
    );
  }

  String _formatShortDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ── String parsing helpers ─────────────────────────────────────────────────

  // Extract the city name from a location string.
  // "New York, NY, United States" → "New York"
  // "Chicago" → "Chicago"
  String _extractCityFromLocation(String location) {
    // Split by comma and take the first part as the city
    final parts = location.split(',');
    return parts.first.trim();
  }

  // Extract state abbreviation from location string.
  // "New York, NY 10021, USA"  → "NY, United States"
  // "New York, NY, USA"        → "NY, United States"
  // "New York, United States"  → "United States"
  // "Chicago"                  → "United States"
  String _extractState(String location) {
    final parts = location.split(',');
    if (parts.length >= 2) {
      final statePart = parts[2].trim();
      // If it's already a country name, return as-is
      if (statePart.toLowerCase() == 'united states' ||
          statePart.toLowerCase() == 'usa' ||
          statePart.toLowerCase() == 'us') {
        return 'United States';
      }
      // "NY 10021" → take only the first word (state code, strip zip)
      final stateCode = statePart.split(' ').first.trim();
      return '$stateCode, United States';
    }
    return 'United States';
  }

  // Clean up the event title to use as trip purpose.
  // Remove destination names if they appear in the title.
  // "Business Trip - New York" → "Business Trip"
  // "NYC Conference 2026" → "NYC Conference 2026"
  String _cleanEventTitle(String title) {
    // Remove common separators and what follows them
    final separators = [' - ', ' – ', ' | ', ': '];
    for (final sep in separators) {
      if (title.contains(sep)) {
        return title.split(sep).first.trim();
      }
    }
    return title.trim();
  }

  // Try to extract a company name from the event description.
  // Looks for patterns like "Company: Acme Corp" or "Client: Acme Corp"
  String _extractCompany(String description) {
    if (description.isEmpty) return 'Client Meeting';

    final patterns = ['company:', 'client:', 'with:', 'at:'];
    final lower = description.toLowerCase();

    for (final pattern in patterns) {
      final index = lower.indexOf(pattern);
      if (index != -1) {
        // Extract text after the pattern until newline or end
        final start = index + pattern.length;
        final end = description.indexOf('\n', start);
        final company = description
            .substring(start, end == -1 ? null : end)
            .trim();
        if (company.isNotEmpty) return company;
      }
    }

    return 'Client Meeting';
  }

  // Guess the main airport for common destination cities.
  // In a real app this would be an API call to an airport database.
  String _guessAirport(String city) {
    const airports = {
      'new york': 'JFK, John F. Kennedy International Airport, Terminal 4',
      'los angeles': 'LAX, Los Angeles International Airport, Terminal 5',
      'chicago': 'ORD, O\'Hare International Airport, Terminal 3',
      'miami': 'MIA, Miami International Airport, Terminal D',
      'boston': 'BOS, Logan International Airport, Terminal B',
      'seattle': 'SEA, Seattle-Tacoma International Airport, Terminal S',
      'denver': 'DEN, Denver International Airport, Terminal B',
      'atlanta': 'ATL, Hartsfield-Jackson Atlanta Airport, Terminal T',
      'dallas': 'DFW, Dallas/Fort Worth International Airport, Terminal D',
      'washington': 'DCA, Ronald Reagan Washington National Airport, Terminal B',
    };

    final lower = city.toLowerCase();
    for (final entry in airports.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    // Default fallback for cities not in our list
    return '$city International Airport, Terminal 1';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXTENSION — Date parsing helper
// ─────────────────────────────────────────────────────────────────────────────
//
// Google Calendar API returns dates as a custom DateTime object.
// This extension adds a toDateTime() method to convert it to Dart's
// standard DateTime class that we use throughout the app.

extension on DateTime {
  // This extension is intentionally minimal — just converts the
  // Google Calendar date format to a standard Dart DateTime
  DateTime toDateTime() => this;
}