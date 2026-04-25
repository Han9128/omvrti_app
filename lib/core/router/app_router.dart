// HOW go_router WORKS:
// Every screen gets a unique path string.
// To navigate you call context.go('/some/path')
// go_router matches the path and builds the right screen.
//
// This is similar to how websites work —
// each page has its own URL.

import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/widgets/main_shell.dart';
import 'package:omvrti_app/features/autopilot/model/trip_model.dart';
import 'package:omvrti_app/features/auth/view/screens/signup_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/autopilot_alert_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/autopilot_flight_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/autopilot_hotel_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/car_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/manual_trip_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/notification_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/payment_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/rewards_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/setting_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/summary_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/autopilot_trips_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/trip_screen.dart';
import 'package:omvrti_app/features/auth/view/screens/login_screen.dart';
import 'package:omvrti_app/features/calendar/view/screens/calendar_integration_screen.dart';
import 'package:omvrti_app/features/calendar/view/screens/calendar_connected_screen.dart';
import 'package:omvrti_app/features/calendar/view/screens/calendar_sync_settings_screen.dart';
import 'package:omvrti_app/features/home/view/home_screen.dart';
import 'package:omvrti_app/features/payment/model/payment_result.dart';
import 'package:omvrti_app/features/payment/view/screens/booking_confirmed_screen.dart';

class AppRouter {
  AppRouter._();

  // The router instance — created once, used everywhere
  // 'static' means it belongs to the CLASS not an instance
  // You access it as AppRouter.router — no object needed

  static final GoRouter router = GoRouter(
    // initialLocation is the first screen shown when app launches
    // Like a website's homepage
    initialLocation: '/login',

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/autopilot/manual-trip',
            name: 'autopilot-manual-trip',
            builder: (context, state) =>
                ManualTripScreen(initialTrip: state.extra as TripModel?),
          ),
          GoRoute(
            path: '/autopilot/alert',
            // name is optional but useful — lets you navigate by name
            // instead of hardcoding path strings everywhere
            name: 'autopilot-alert',

            // builder returns the widget to show for this route
            // state contains route parameters if any (we will use this later)
            builder: (context, state) => const AutopilotAlertScreen(),
          ),

          GoRoute(
            path: '/autopilot/flight',
            name: 'autopilot-flight',
            builder: (context, state) => const AutopilotFlightScreen(),
          ),

          GoRoute(
            path: '/autopilot/hotel',
            name: 'autopilot-hotel',
            builder: (context, state) => const AutopilotHotelScreen(),
          ),

          GoRoute(
            path: '/autopilot/car',
            name: 'autopilot-car',
            builder: (context, state) => const AutopilotCarScreen(),
          ),

          GoRoute(
            path: '/autopilot/summary',
            name: 'autopilot-summary',
            builder: (context, state) => const AutopilotSummaryScreen(),
          ),

          GoRoute(
            path: '/autopilot/payment',
            name: 'autopilot-payment',
            builder: (context, state) => const PaymentScreen(),
          ),

          GoRoute(
  path: '/payment/confirmed',
  builder: (context, state) => BookingConfirmedScreen(
    paymentResult: state.extra as PaymentResult,
  ),
),

          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarIntegrationScreen(),
          ),
          GoRoute(
            path: '/calendar/connected',
            builder: (context, state) => const CalendarConnectedScreen(),
          ),
          GoRoute(
            path: '/calendar/sync-settings',
            builder: (context, state) => const CalendarSyncSettingsScreen(),
          ),

          GoRoute(
            path: '/trips',
            name: 'trips',
            builder: (context, state) => const TripScreen(),
          ),
          GoRoute(
            path: '/trips/autopilot',
            builder: (context, state) => const AutopilotTripsScreen(),
          ),
          GoRoute(
            path: '/rewards',
            name: 'rewards',
            builder: (context, state) => const RewardsScreen(),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingScreen(),
          ),
        ],
      ),
    ],
  );
}
