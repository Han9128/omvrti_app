// // ─────────────────────────────────────────────────────────────────────────────
// // APP DRAWER  (lib/core/widgets/app_drawer.dart)
// // ─────────────────────────────────────────────────────────────────────────────
// //
// // This is the slide-in hamburger menu that opens when the user taps ☰
// // in OmvrtiAppBar on any main tab screen.
// //
// // HOW FLUTTER'S DRAWER SYSTEM WORKS (important concept):
// // ─────────────────────────────────────────────────────────────────────────────
// //   Flutter's Scaffold has a built-in `drawer:` slot.
// //   When you call Scaffold.of(context).openDrawer() from ANY widget that
// //   is a descendant of that Scaffold, Flutter slides in the drawer from
// //   the left with a smooth animation + dark barrier behind it automatically.
// //
// //   Think of it like this:
// //     Scaffold (lives in MainShell)
// //       ├── drawer: AppDrawer()       ← registered here
// //       └── body: child               ← OmvrtiAppBar lives somewhere inside body
// //            └── OmvrtiAppBar
// //                 └── hamburger tap → Scaffold.of(context).openDrawer()
// //
// //   The Scaffold.of(context) call walks UP the widget tree to find the
// //   nearest Scaffold ancestor — no GlobalKey or state passing needed.
// //
// // DESIGN STRUCTURE:
// //   ┌─────────────────────────────┐
// //   │ OmVrti.ai logo       [  X ] │  ← header
// //   ├─────────────────────────────┤
// //   │  Trips                      │  ← section label (gray, small)
// //   │  🧳 My Bookings             │  ← menu item
// //   │  💼 Trip Planner            │
// //   │  🕐 Travel History          │
// //   │                             │
// //   │  Rewards                    │
// //   │  🎁 OmVrti.ai Rewards       │
// //   │                             │
// //   │  Profile                    │
// //   │  👤 My Profile              │
// //   │  ⚙  My Preferences          │
// //   │  🪪 Travel Policy           │
// //   │  💳 Payment Methods         │
// //   │  👛 My Wallet               │
// //   │                             │
// //   │  Support                    │
// //   │  ❓ Help                    │
// //   │  📞 Contact Us              │
// //   │                             │
// //   │  Settings                   │
// //   │  🔔 Notifications           │
// //   └─────────────────────────────┘

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:omvrti_app/core/constants/constants.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // DATA MODELS
// // ─────────────────────────────────────────────────────────────────────────────
// //
// // We model the menu as data (sections + items) rather than hardcoding
// // widget trees. This makes adding, removing, or reordering menu items
// // as easy as editing a list — no UI code changes needed.

// /// One tappable row in the drawer: an icon + a text label.
// class _MenuItem {
//   final IconData icon;
//   final String label;

//   /// The route to navigate to. null = not yet implemented (no-op tap).
//   final String? route;

//   const _MenuItem({
//     required this.icon,
//     required this.label,
//     this.route,
//   });
// }

// /// A named group of menu items with a section header above them.
// class _MenuSection {
//   final String title; // e.g. "Trips", "Profile"
//   final List<_MenuItem> items;

//   const _MenuSection({required this.title, required this.items});
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // APP DRAWER WIDGET
// // ─────────────────────────────────────────────────────────────────────────────

// class AppDrawer extends StatelessWidget {
//   const AppDrawer({super.key});

//   // ── Menu Data ───────────────────────────────────────────────────────────────
//   // All menu sections and their items defined as a static list.
//   // Outline-style icons are used throughout to match the design's clean look.

//   static const List<_MenuSection> _sections = [
//     _MenuSection(
//       title: 'Trips',
//       items: [
//         _MenuItem(
//           icon: Icons.luggage_outlined,
//           label: 'My Bookings',
//           route: '/trips',
//         ),
//         _MenuItem(
//           icon: Icons.work_outline_rounded,
//           label: 'Trip Planner',
//           route: '/trips',
//         ),
//         _MenuItem(
//           icon: Icons.history_rounded,
//           label: 'Travel History',
//           route: '/trips',
//         ),
//       ],
//     ),
//     _MenuSection(
//       title: 'Rewards',
//       items: [
//         _MenuItem(
//           icon: Icons.card_giftcard_outlined,
//           label: 'OmVrti.ai Rewards',
//           // Not yet implemented — null means no navigation
//           route: null,
//         ),
//       ],
//     ),
//     _MenuSection(
//       title: 'Profile',
//       items: [
//         _MenuItem(
//           icon: Icons.person_outline_rounded,
//           label: 'My Profile',
//           route: null,
//         ),
//         _MenuItem(
//           icon: Icons.settings_outlined,
//           label: 'My Preferences',
//           route: '/settings',
//         ),
//         _MenuItem(
//           icon: Icons.badge_outlined,
//           label: 'Travel Policy',
//           route: null,
//         ),
//         _MenuItem(
//           icon: Icons.credit_card_outlined,
//           label: 'Payment Methods',
//           route: null,
//         ),
//         _MenuItem(
//           icon: Icons.account_balance_wallet_outlined,
//           label: 'My Wallet',
//           route: null,
//         ),
//       ],
//     ),
//     _MenuSection(
//       title: 'Support',
//       items: [
//         _MenuItem(
//           icon: Icons.help_outline_rounded,
//           label: 'Help',
//           route: null,
//         ),
//         _MenuItem(
//           icon: Icons.phone_outlined,
//           label: 'Contact Us',
//           route: null,
//         ),
//       ],
//     ),
//     _MenuSection(
//       title: 'Settings',
//       items: [
//         _MenuItem(
//           icon: Icons.notifications_outlined,
//           label: 'Notifications',
//           route: '/notifications',
//         ),
//       ],
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       // Pure white background — matches the design exactly
//       backgroundColor: AppColors.surface,

//       // elevation: 0 removes the default shadow on the drawer's right edge.
//       // The design shows a clean hard edge, not a drop-shadow.
//       elevation: 0,

//       // Width: 82% of screen width. Flutter's default is ~304px which can feel
//       // narrow. 82% gives the near-full-width look shown in the design while
//       // still leaving a sliver visible so users know how to dismiss it.
//       width: MediaQuery.of(context).size.width * 0.82,

//       child: SafeArea(
//         // SafeArea handles notches and status bars — the logo won't overlap
//         // the status bar on any device.
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── 1. Header row (logo + close button) ─────────────────────
//             _buildHeader(context),

//             // ── 2. Scrollable menu list ──────────────────────────────────
//             // Expanded fills all remaining vertical space.
//             // SingleChildScrollView makes the list scroll on small phones
//             // where content might exceed screen height.
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.fromLTRB(
//                   AppSpacing.xl,   // left
//                   AppSpacing.sm,   // top
//                   AppSpacing.xl,   // right
//                   AppSpacing.xxl,  // bottom — breathing room at the end
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Build each section with a gap between them.
//                     // The for-loop + spread operator (...) lets us insert
//                     // spacing between sections without an index counter.
//                     for (int i = 0; i < _sections.length; i++) ...[
//                       _buildSection(context, _sections[i]),
//                       // Space between sections, but NOT after the last one
//                       if (i < _sections.length - 1)
//                         const SizedBox(height: AppSpacing.xl),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Header ─────────────────────────────────────────────────────────────────
//   // OmVrti.ai logo on the left, ✕ close button on the right.
//   // Matches the design's header row exactly.

//   Widget _buildHeader(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(
//         AppSpacing.xl,   // left padding — aligns with menu items below
//         AppSpacing.lg,   // top padding
//         AppSpacing.lg,   // right padding
//         AppSpacing.lg,   // bottom padding
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Brand logo — same three-color RichText as OmvrtiAppBar
//           // "Om" + "V" (accent) + "rti.ai"
//           RichText(
//             text: TextSpan(
//               children: [
//                 TextSpan(
//                   text: 'Om',
//                   style: AppTextStyles.h3.copyWith(
//                     color: const Color(0xFF1A3C8F),
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 TextSpan(
//                   text: 'V',
//                   style: AppTextStyles.h3.copyWith(
//                     color: AppColors.accent,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 TextSpan(
//                   text: 'rti.ai',
//                   style: AppTextStyles.h3.copyWith(
//                     color: const Color(0xFF1A3C8F),
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ✕ Close button
//           // GestureDetector + Container gives us a generous tap target (40x40)
//           // without adding a visible background — just the icon is shown.
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             // Minimum 44x44 tap target — Apple HIG & Material accessibility guideline
//             child: Container(
//               width: 40,
//               height: 40,
//               alignment: Alignment.center,
//               child: Icon(
//                 Icons.close_rounded,
//                 color: AppColors.textSecondary,
//                 size: 22,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Section ─────────────────────────────────────────────────────────────────
//   // Renders a section header + the items below it.
//   //
//   // Section header: small gray text like "Trips", "Profile"
//   // Then all the items for that section below (no dividers between items).

//   Widget _buildSection(BuildContext context, _MenuSection section) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Section label — small, gray, gives hierarchy to the list
//         Text(
//           section.title,
//           style: AppTextStyles.label.copyWith(
//             color: AppColors.textMuted,
//             fontWeight: FontWeight.w600,
//             fontSize: 12,
//             letterSpacing: 0.2,
//           ),
//         ),
//         // Minimal gap between label and first item
//         const SizedBox(height: AppSpacing.xs),

//         // All items in this section
//         for (final item in section.items)
//           _buildMenuItem(context, item),
//       ],
//     );
//   }

//   // ── Menu Item ──────────────────────────────────────────────────────────────
//   // A single tappable row: [Icon]  [Label text]
//   //
//   // WHY InkWell instead of GestureDetector?
//   //   InkWell gives the Material ripple effect on tap — the visual feedback
//   //   that something was pressed. For list items, this is the correct
//   //   Material pattern. The borderRadius clips the ripple to rounded corners.
//   //
//   // WHY Builder?
//   //   Builder creates a new BuildContext that is a descendant of the InkWell.
//   //   This ensures theme data (like ink color) resolves correctly from the
//   //   nearest Theme ancestor.

//   Widget _buildMenuItem(BuildContext context, _MenuItem item) {
//     return InkWell(
//       onTap: item.route != null
//           ? () => _handleItemTap(context, item.route!)
//           : null, // null onTap = visually tappable but no action + no ripple
//       borderRadius: BorderRadius.circular(AppSpacing.sm),
//       // Ripple color — subtle primary blue tint on tap
//       splashColor: AppColors.primary.withOpacity(0.06),
//       highlightColor: AppColors.primary.withOpacity(0.04),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//           // Vertical padding gives each row enough height (matches design ~48px rows)
//           vertical: AppSpacing.md,
//           // Small horizontal padding so the ripple doesn't touch the left edge
//           horizontal: AppSpacing.xs,
//         ),
//         child: Row(
//           children: [
//             // Menu icon — outlined style, primary text color
//             // Size 22 matches the proportions in the design
//             Icon(
//               item.icon,
//               size: 22,
//               // Slightly dimmed color for icons — matching the design's gray icons
//               color: item.route != null
//                   ? AppColors.textPrimary
//                   : AppColors.textMuted, // dim unimplemented items
//             ),
//             const SizedBox(width: AppSpacing.md),

//             // Label text
//             Text(
//               item.label,
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: item.route != null
//                     ? AppColors.textPrimary
//                     : AppColors.textMuted, // dim unimplemented items
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Navigation Handler ─────────────────────────────────────────────────────
//   // Close the drawer THEN navigate.
//   //
//   // WHY close before navigating?
//   //   If we navigate immediately, two animations run at the same time:
//   //   the drawer sliding out AND the new page sliding in. On slower devices
//   //   this looks choppy. Closing first, then navigating after a short delay,
//   //   lets each animation complete cleanly.
//   //
//   // The 200ms delay is imperceptible to users but gives the drawer
//   // close animation time to complete before the page push starts.

//   void _handleItemTap(BuildContext context, String route) {
//     // Step 1: Close the drawer
//     // Navigator.pop() removes the drawer from the navigation stack.
//     // Flutter automatically plays the slide-out animation.
//     Navigator.pop(context);

//     // Step 2: Navigate after the drawer finishes closing
//     Future.delayed(const Duration(milliseconds: 200), () {
//       // context.mounted check: ensures the widget is still in the tree
//       // before we try to use its context for navigation.
//       // This prevents "setState called after dispose" type errors.
//       if (context.mounted) {
//         // context.go() replaces the current route — correct for main nav.
//         // We use go() not push() so the back button doesn't return to the
//         // previous tab (e.g. going from Home → Trips should not let user
//         // "go back" to Home with the back button — they use the nav bar).
//         context.go(route);
//       }
//     });
//   }
// }


// ─────────────────────────────────────────────────────────────────────────────
// APP DRAWER  (lib/core/widgets/app_drawer.dart)
// ─────────────────────────────────────────────────────────────────────────────
//
// This is the slide-in hamburger menu that opens when the user taps ☰
// in OmvrtiAppBar on any main tab screen.
//
// HOW FLUTTER'S DRAWER SYSTEM WORKS (important concept):
// ─────────────────────────────────────────────────────────────────────────────
//   Flutter's Scaffold has a built-in `drawer:` slot.
//   When you call Scaffold.of(context).openDrawer() from ANY widget that
//   is a descendant of that Scaffold, Flutter slides in the drawer from
//   the left with a smooth animation + dark barrier behind it automatically.
//
//   Think of it like this:
//     Scaffold (lives in MainShell)
//       ├── drawer: AppDrawer()       ← registered here
//       └── body: child               ← OmvrtiAppBar lives somewhere inside body
//            └── OmvrtiAppBar
//                 └── hamburger tap → Scaffold.of(context).openDrawer()
//
//   The Scaffold.of(context) call walks UP the widget tree to find the
//   nearest Scaffold ancestor — no GlobalKey or state passing needed.
//
// DESIGN STRUCTURE:
//   ┌─────────────────────────────┐
//   │ OmVrti.ai logo       [  X ] │  ← header
//   ├─────────────────────────────┤
//   │  Trips                      │  ← section label (gray, small)
//   │  🧳 My Bookings             │  ← menu item
//   │  💼 Trip Planner            │
//   │  🕐 Travel History          │
//   │                             │
//   │  Rewards                    │
//   │  🎁 OmVrti.ai Rewards       │
//   │                             │
//   │  Profile                    │
//   │  👤 My Profile              │
//   │  ⚙  My Preferences          │
//   │  🪪 Travel Policy           │
//   │  💳 Payment Methods         │
//   │  👛 My Wallet               │
//   │                             │
//   │  Support                    │
//   │  ❓ Help                    │
//   │  📞 Contact Us              │
//   │                             │
//   │  Settings                   │
//   │  🔔 Notifications           │
//   └─────────────────────────────┘

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
//
// We model the menu as data (sections + items) rather than hardcoding
// widget trees. This makes adding, removing, or reordering menu items
// as easy as editing a list — no UI code changes needed.

/// One tappable row in the drawer: an icon + a text label.
class _MenuItem {
  final IconData icon;
  final String label;

  /// The route to navigate to. null = not yet implemented (no-op tap).
  final String? route;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.route,
  });
}

/// A named group of menu items with a section header above them.
class _MenuSection {
  final String title; // e.g. "Trips", "Profile"
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});
}

// ─────────────────────────────────────────────────────────────────────────────
// APP DRAWER WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // ── Menu Data ───────────────────────────────────────────────────────────────
  // All menu sections and their items defined as a static list.
  // Outline-style icons are used throughout to match the design's clean look.

  static const List<_MenuSection> _sections = [
    _MenuSection(
      title: 'Trips',
      items: [
        _MenuItem(
          icon: Icons.luggage_outlined,
          label: 'My Bookings',
          route: '/trips',
        ),
        _MenuItem(
          icon: Icons.work_outline_rounded,
          label: 'Trip Planner',
          route: '/trips',
        ),
        _MenuItem(
          icon: Icons.history_rounded,
          label: 'Travel History',
          route: '/trips',
        ),
      ],
    ),
    _MenuSection(
      title: 'Rewards',
      items: [
        _MenuItem(
          icon: Icons.card_giftcard_outlined,
          label: 'OmVrti.ai Rewards',
          // Not yet implemented — null means no navigation
          route: null,
        ),
      ],
    ),
    _MenuSection(
      title: 'Profile',
      items: [
        _MenuItem(
          icon: Icons.person_outline_rounded,
          label: 'My Profile',
          route: null,
        ),
        _MenuItem(
          icon: Icons.settings_outlined,
          label: 'My Preferences',
          route: '/settings',
        ),
        _MenuItem(
          icon: Icons.badge_outlined,
          label: 'Travel Policy',
          route: null,
        ),
        _MenuItem(
          icon: Icons.credit_card_outlined,
          label: 'Payment Methods',
          route: null,
        ),
        _MenuItem(
          icon: Icons.account_balance_wallet_outlined,
          label: 'My Wallet',
          route: null,
        ),
      ],
    ),
    _MenuSection(
      title: 'Support',
      items: [
        _MenuItem(
          icon: Icons.help_outline_rounded,
          label: 'Help',
          route: null,
        ),
        _MenuItem(
          icon: Icons.phone_outlined,
          label: 'Contact Us',
          route: null,
        ),
      ],
    ),
    _MenuSection(
      title: 'Settings',
      items: [
        _MenuItem(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          route: '/notifications',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Pure white background — matches the design exactly
      backgroundColor: AppColors.surface,

      // elevation: 0 removes the default shadow on the drawer's right edge.
      // The design shows a clean hard edge, not a drop-shadow.
      elevation: 0,

      // Width: 82% of screen width. Flutter's default is ~304px which can feel
      // narrow. 82% gives the near-full-width look shown in the design while
      // still leaving a sliver visible so users know how to dismiss it.
      width: MediaQuery.of(context).size.width * 0.82,

      child: SafeArea(
        // SafeArea handles notches and status bars — the logo won't overlap
        // the status bar on any device.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Header row (logo + close button) ─────────────────────
            _buildHeader(context),

            // ── 2. Scrollable menu list ──────────────────────────────────
            // Expanded fills all remaining vertical space.
            // SingleChildScrollView makes the list scroll on small phones
            // where content might exceed screen height.
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,   // left
                  AppSpacing.sm,   // top
                  AppSpacing.xl,   // right
                  AppSpacing.xxl,  // bottom — breathing room at the end
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Build each section with a gap between them.
                    // The for-loop + spread operator (...) lets us insert
                    // spacing between sections without an index counter.
                    for (int i = 0; i < _sections.length; i++) ...[
                      _buildSection(context, _sections[i]),
                      // Space between sections, but NOT after the last one
                      if (i < _sections.length - 1)
                        const SizedBox(height: AppSpacing.xl),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  // OmVrti.ai logo on the left, ✕ close button on the right.
  // Matches the design's header row exactly.

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,   // left padding — aligns with menu items below
        AppSpacing.lg,   // top padding
        AppSpacing.lg,   // right padding
        AppSpacing.lg,   // bottom padding
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand logo — same three-color RichText as OmvrtiAppBar
          // "Om" + "V" (accent) + "rti.ai"
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Om',
                  style: AppTextStyles.h3.copyWith(
                    color: const Color(0xFF1A3C8F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'V',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'rti.ai',
                  style: AppTextStyles.h3.copyWith(
                    color: const Color(0xFF1A3C8F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // ✕ Close button
          // GestureDetector + Container gives us a generous tap target (40x40)
          // without adding a visible background — just the icon is shown.
          GestureDetector(
            onTap: () => Navigator.pop(context),
            // Minimum 44x44 tap target — Apple HIG & Material accessibility guideline
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section ─────────────────────────────────────────────────────────────────
  // Renders a section header + the items below it.
  //
  // Section header: small gray text like "Trips", "Profile"
  // Then all the items for that section below (no dividers between items).

  Widget _buildSection(BuildContext context, _MenuSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label — small, gray, gives hierarchy to the list
        Text(
          section.title,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.2,
          ),
        ),
        // Minimal gap between label and first item
        const SizedBox(height: AppSpacing.xs),

        // All items in this section
        for (final item in section.items)
          _buildMenuItem(context, item),
      ],
    );
  }

  // ── Menu Item ──────────────────────────────────────────────────────────────
  // A single tappable row: [Icon]  [Label text]
  //
  // WHY InkWell instead of GestureDetector?
  //   InkWell gives the Material ripple effect on tap — the visual feedback
  //   that something was pressed. For list items, this is the correct
  //   Material pattern. The borderRadius clips the ripple to rounded corners.
  //
  // WHY Builder?
  //   Builder creates a new BuildContext that is a descendant of the InkWell.
  //   This ensures theme data (like ink color) resolves correctly from the
  //   nearest Theme ancestor.

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return InkWell(
      onTap: item.route != null
          ? () => _handleItemTap(context, item.route!)
          : null, // null onTap = visually tappable but no action + no ripple
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      // Ripple color — subtle primary blue tint on tap
      splashColor: AppColors.primary.withOpacity(0.06),
      highlightColor: AppColors.primary.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          // Vertical padding gives each row enough height (matches design ~48px rows)
          vertical: AppSpacing.md,
          // Small horizontal padding so the ripple doesn't touch the left edge
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            // Menu icon — outlined style, primary text color
            // Size 22 matches the proportions in the design
            Icon(
              item.icon,
              size: 22,
              // Slightly dimmed color for icons — matching the design's gray icons
              // color: item.route != null
              //     ? AppColors.textPrimary
              //     : AppColors.textMuted, // dim unimplemented items
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.md),

            // Label text
            Text(
              item.label,
              style: AppTextStyles.bodyMedium.copyWith(
                // color: item.route != null
                //     ? AppColors.textPrimary
                //     : AppColors.textMuted, // dim unimplemented items
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation Handler ─────────────────────────────────────────────────────
  // Close the drawer THEN navigate.
  //
  // WHY close before navigating?
  //   If we navigate immediately, two animations run at the same time:
  //   the drawer sliding out AND the new page sliding in. On slower devices
  //   this looks choppy. Closing first, then navigating after a short delay,
  //   lets each animation complete cleanly.
  //
  // The 200ms delay is imperceptible to users but gives the drawer
  // close animation time to complete before the page push starts.

  void _handleItemTap(BuildContext context, String route) {
    // Step 1: Close the drawer
    // Navigator.pop() removes the drawer from the navigation stack.
    // Flutter automatically plays the slide-out animation.
    Navigator.pop(context);

    // Step 2: Navigate after the drawer finishes closing
    Future.delayed(const Duration(milliseconds: 200), () {
      // context.mounted check: ensures the widget is still in the tree
      // before we try to use its context for navigation.
      // This prevents "setState called after dispose" type errors.
      if (context.mounted) {
        // context.go() replaces the current route — correct for main nav.
        // We use go() not push() so the back button doesn't return to the
        // previous tab (e.g. going from Home → Trips should not let user
        // "go back" to Home with the back button — they use the nav bar).
        context.go(route);
      }
    });
  }
}