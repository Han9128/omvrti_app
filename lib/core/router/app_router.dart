// HOW go_router WORKS:
// Every screen gets a unique path string.
// To navigate you call context.go('/some/path')
// go_router matches the path and builds the right screen.
//
// This is similar to how websites work —
// each page has its own URL.

import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/widgets/main_shell.dart';
import 'package:omvrti_app/features/autopilot/view/screens/autopilot_alert_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/autopilot_flight_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/notification_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/setting_screen.dart';
import 'package:omvrti_app/features/autopilot/view/screens/trip_screen.dart';

class AppRouter {
  AppRouter._();

  // The router instance — created once, used everywhere
  // 'static' means it belongs to the CLASS not an instance
  // You access it as AppRouter.router — no object needed

  static final GoRouter router = GoRouter(
    // initialLocation is the first screen shown when app launches
    // Like a website's homepage
    initialLocation: '/autopilot/alert',

    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
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
            path: '/trips',
            name: 'trips',
            builder: (context, state) => const TripScreen(),
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
