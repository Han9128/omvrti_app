// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:go_router/go_router.dart';
// import '../constants/constants.dart';

// class MainShell extends StatelessWidget {
//   final Widget child;
//   const MainShell({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//         systemNavigationBarColor: Colors.transparent,
//         systemNavigationBarIconBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//         backgroundColor: AppColors.surface,
//         body: child,
//         bottomNavigationBar: _buildBottomNav(context),
//       ),
//     );
//   }

//   Widget _buildBottomNav(BuildContext context) {
//     final String currentPath = GoRouterState.of(context).matchedLocation;
//     final int currentIndex = _pathToIndex(currentPath);

//     return Container(
//       color: AppColors.surface,
//       child: SafeArea(
//         top: false,
//         child: SizedBox(
//           height: 68,
//           child: Row(
//             children: [
//               _buildNavItem(
//                 context: context,
//                 index: 0,
//                 svgPath: AppImages.navHome,
//                 label: 'Home',
//                 path: '/home',
//                 currentIndex: currentIndex,
//               ),
//               _buildNavItem(
//                 context: context,
//                 index: 1,
//                 svgPath: AppImages.navTrip,
//                 label: 'Trip Planner',
//                 path: '/trips',
//                 currentIndex: currentIndex,
//               ),
//               _buildNavItem(
//                 context: context,
//                 index: 2,
//                 svgPath: AppImages.navReward,
//                 label: 'Rewards',
//                 path: '/rewards',
//                 currentIndex: currentIndex,
//               ),
//               _buildNavItem(
//                 context: context,
//                 index: 3,
//                 svgPath: AppImages.navNotification,
//                 label: 'Notifications',
//                 path: '/notifications',
//                 currentIndex: currentIndex,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required BuildContext context,
//     required int index,
//     required String svgPath,
//     required String label,
//     required String path,
//     required int currentIndex,
//   }) {
//     final bool isActive = currentIndex == index;

//     return Expanded(
//       child: GestureDetector(
//         onTap: () => context.go(path),
//         behavior: HitTestBehavior.opaque,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Blue top indicator — visible only for the active tab
//             Container(
//               height: 3,
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               decoration: BoxDecoration(
//                 color: isActive ? AppColors.primary : Colors.transparent,
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(3),
//                   bottomRight: Radius.circular(3),
//                 ),
//               ),
//             ),

//             // Icon + label centered in remaining space
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Light blue pill background when active
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 5,
//                     ),
//                     decoration: isActive
//                         ? BoxDecoration(
//                             color: const Color(0xFFE8F0FF),
//                             borderRadius: BorderRadius.circular(20),
//                           )
//                         : null,
//                     child: Image.asset(
//                       svgPath,
//                       width: 28,
//                       height: 28,
//                       fit: BoxFit.contain,
//                     ),
//                   ),

//                   const SizedBox(height: 4),

//                   Text(
//                     label,
//                     maxLines: 1,
//                     style: AppTextStyles.bodySmall.copyWith(
//                       fontSize: 10,
//                       color: isActive ? AppColors.primary : AppColors.textMuted,
//                       fontWeight:
//                           isActive ? FontWeight.w600 : FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   int _pathToIndex(String path) {
//     if (path.startsWith('/home')) return 0;
//     if (path.startsWith('/autopilot')) return 0;
//     if (path.startsWith('/trips')) return 1;
//     if (path.startsWith('/rewards')) return 2;
//     if (path.startsWith('/notifications')) return 3;
//     return 0;
//   }
// }


// // ─────────────────────────────────────────────────────────────────────────────
// // MAIN SHELL  (lib/core/widgets/main_shell.dart)
// // ─────────────────────────────────────────────────────────────────────────────
// //
// // MainShell is the persistent wrapper around every screen inside the ShellRoute.
// // It provides:
// //   1. The bottom navigation bar (always visible on shell routes)
// //   2. The Scaffold that ALL inner screens share
// //   3. The Drawer (hamburger menu) — registered here so OmvrtiAppBar
// //      can open it via Scaffold.of(context).openDrawer()
// //
// // WHY register the Drawer in MainShell and not in each screen?
// // ─────────────────────────────────────────────────────────────────────────────
// //   The hamburger menu is the SAME on every main tab screen (Home, Trips,
// //   Notifications, Settings). Defining it once here means:
// //   - Zero duplication across screens
// //   - Adding a new shell route automatically gets the drawer
// //   - Screens don't need to know anything about the drawer
// //
// // HOW OmvrtiAppBar opens the drawer:
// // ─────────────────────────────────────────────────────────────────────────────
// //   OmvrtiAppBar calls Scaffold.of(context).openDrawer() when the ☰ is tapped.
// //   Scaffold.of(context) walks UP the widget tree and finds THIS Scaffold.
// //   Flutter then slides AppDrawer in from the left automatically.
// //   No GlobalKey, no state, no callbacks needed.

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:omvrti_app/core/widgets/app_drawer.dart';
// // import '../constants/constants.dart';

// // class MainShell extends StatelessWidget {
// //   final Widget child;
// //   const MainShell({super.key, required this.child});

// //   @override
// //   Widget build(BuildContext context) {
// //     return AnnotatedRegion<SystemUiOverlayStyle>(
// //       value: const SystemUiOverlayStyle(
// //         statusBarColor: Colors.white,
// //         statusBarIconBrightness: Brightness.dark,
// //         statusBarBrightness: Brightness.light,
// //       ),
// //       child: Scaffold(
// //         backgroundColor: AppColors.surface,

// //         // ── THE DRAWER ────────────────────────────────────────────────────
// //         // This is the key line. Registering AppDrawer here means:
// //         //   - Any descendant widget can call Scaffold.of(context).openDrawer()
// //         //   - OmvrtiAppBar (which is inside `child`) can open it
// //         //   - Flutter handles animation, barrier, swipe-to-close automatically
// //         drawer: const AppDrawer(),

// //         // The `child` is whatever screen go_router put here
// //         // (HomeScreen, TripScreen, etc.)
// //         body: child,

// //         // Bottom navigation bar — persistent across all shell routes
// //         bottomNavigationBar: _buildBottomNav(context),
// //       ),
// //     );
// //   }

// //   Widget _buildBottomNav(BuildContext context) {
// //     final String currentPath = GoRouterState.of(context).matchedLocation;
// //     final int currentIndex = _pathToIndex(currentPath);

// //     return Container(
// //       decoration: BoxDecoration(
// //         color: AppColors.surface,
// //         border: Border(
// //           top: BorderSide(color: AppColors.textMuted, width: 1),
// //         ),
// //       ),
// //       child: SafeArea(
// //         top: false,
// //         child: SizedBox(
// //           height: 60,
// //           child: Row(
// //             children: [
// //               _buildNavItem(
// //                 context: context,
// //                 index: 0,
// //                 icon: Icons.home_outlined,
// //                 activeIcon: Icons.home_rounded,
// //                 label: 'Home',
// //                 path: '/home',
// //                 currentIndex: currentIndex,
// //               ),
// //               _buildNavItem(
// //                 context: context,
// //                 index: 1,
// //                 icon: Icons.flight_outlined,
// //                 activeIcon: Icons.flight_rounded,
// //                 label: 'Trips',
// //                 path: '/trips',
// //                 currentIndex: currentIndex,
// //               ),
// //               _buildNavItem(
// //                 context: context,
// //                 index: 2,
// //                 icon: Icons.notifications_outlined,
// //                 activeIcon: Icons.notifications_rounded,
// //                 label: 'Notifications',
// //                 path: '/notifications',
// //                 currentIndex: currentIndex,
// //               ),
// //               _buildNavItem(
// //                 context: context,
// //                 index: 3,
// //                 icon: Icons.settings_outlined,
// //                 activeIcon: Icons.settings_rounded,
// //                 label: 'Settings',
// //                 path: '/settings',
// //                 currentIndex: currentIndex,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildNavItem({
// //     required BuildContext context,
// //     required int index,
// //     required IconData icon,
// //     required IconData activeIcon,
// //     required String label,
// //     required String path,
// //     required int currentIndex,
// //   }) {
// //     final bool isActive = currentIndex == index;

// //     return Expanded(
// //       child: GestureDetector(
// //         onTap: () => context.go(path),
// //         behavior: HitTestBehavior.opaque,
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               isActive ? activeIcon : icon,
// //               color: isActive ? AppColors.accent : AppColors.textMuted,
// //             ),
// //             const SizedBox(height: 3),
// //             Text(
// //               label,
// //               style: AppTextStyles.bodySmall.copyWith(
// //                 fontSize: 11,
// //                 color: isActive ? AppColors.accent : AppColors.textMuted,
// //                 fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   int _pathToIndex(String path) {
// //     if (path.startsWith('/home')) return 0;
// //     if (path.startsWith('/trips')) return 1;
// //     if (path.startsWith('/notifications')) return 2;
// //     if (path.startsWith('/settings')) return 3;
// //     return 0;
// //   }
// // }



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/widgets/app_drawer.dart';
import 'package:omvrti_app/core/widgets/profile_drawer.dart';
import '../constants/constants.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        drawer: const AppDrawer(),
        endDrawer: const ProfileDrawer(
          userName: 'Sam Watson',
          userEmail: 'sam.watson@omvrti.ai',
        ),
        body: child,
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final String currentPath = GoRouterState.of(context).matchedLocation;
    final int currentIndex = _pathToIndex(currentPath);

    return Container(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                svgPath: AppImages.navHome,
                label: 'Home',
                path: '/home',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context: context,
                index: 1,
                svgPath: AppImages.navTrip,
                label: 'Trip Planner',
                path: '/trips',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context: context,
                index: 2,
                svgPath: AppImages.navReward,
                label: 'Rewards',
                path: '/rewards',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context: context,
                index: 3,
                svgPath: AppImages.navNotification,
                label: 'Notifications',
                path: '/notifications',
                currentIndex: currentIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String svgPath,
    required String label,
    required String path,
    required int currentIndex,
  }) {
    final bool isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(path),
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: isActive
                        ? BoxDecoration(
                            color: const Color(0xFFE8F0FF),
                            borderRadius: BorderRadius.circular(20),
                          )
                        : null,
                    child: Image.asset(
                      svgPath,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10,
                      color: isActive ? AppColors.primary : AppColors.textMuted,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _pathToIndex(String path) {
    if (path.startsWith('/home')) return 0;
    if (path.startsWith('/autopilot')) return 0;
    if (path.startsWith('/trips')) return 1;
    if (path.startsWith('/rewards')) return 2;
    if (path.startsWith('/notifications')) return 3;
    return 0;
  }
}