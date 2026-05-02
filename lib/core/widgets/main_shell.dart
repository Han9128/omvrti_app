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
    // if (path.startsWith('/autopilot')) return 0;
    if (path.startsWith('/trips')) return 1;
    if (path.startsWith('/rewards')) return 2;
    if (path.startsWith('/notifications')) return 3;
    return 0;
  }
}