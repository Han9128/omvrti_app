import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../constants/constants.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: child,
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final String currentPath = GoRouterState.of(context).matchedLocation;
    final int currentIndex = _pathToIndex(currentPath);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.textMuted, width: 1)),
      ),

      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                path: '/home',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.flight_outlined,
                activeIcon: Icons.flight_rounded,
                label: 'Trips',
                path: '/trips',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications_rounded,
                label: 'Notifications',
                path: '/notifications',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context: context,
                index: 3,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: 'Settings',
                path: '/settings',
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
    required IconData icon,
    required IconData activeIcon,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.accent : AppColors.textMuted,
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: isActive ? AppColors.accent : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _pathToIndex(String path) {
    // All autopilot screens fall under Home tab (index 0)
    // because Home IS the autopilot alert screen
    if (path.startsWith('/home')) return 0;
    if (path.startsWith('/trips')) return 1;
    if (path.startsWith('/notifications')) return 2;
    if (path.startsWith('/settings')) return 3;
    return 0; // default to Home
  }
}
