// HomeService is the DATA LAYER for the Home Screen.
//
// Currently it handles two things:
//   1. Fetching the current user's profile (name, reward points)
//   2. Connecting Google Calendar (mock for now)
//
// When real APIs are ready, only this file changes.
// The ViewModel and UI stay exactly the same.

class HomeService {
  // fetchUserProfile() simulates a GET /user/profile API call.
  //
  // Returns a Map with user data.
  // In a real app this would return a UserModel.
  // We use a Map for now to keep things simple before
  // the UserModel is formally defined.
  Future<Map<String, dynamic>> fetchUserProfile() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock response — replace with real HTTP call later
    return {
      'userName': 'Sam Watson',
      'rewardPoints': 0,
      'isCalendarConnected': false,
    };
  }

  // connectGoogleCalendar() simulates the OAuth flow for Google Calendar.
  //
  // In the real implementation this will:
  //   1. Launch Google OAuth consent screen
  //   2. Receive the auth token
  //   3. Store it securely
  //   4. Return success/failure
  //
  // Returns true on success, throws on failure.
  Future<bool> connectGoogleCalendar() async {
    // Simulate OAuth delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock: always succeeds for now
    // Replace with real OAuth package (e.g. google_sign_in) later
    return true;
  }

  // getGreeting() returns the correct greeting based on current time.
  //
  // This is pure logic with no async work — it belongs in the service
  // layer because it's a "data transformation" not a UI concern.
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}