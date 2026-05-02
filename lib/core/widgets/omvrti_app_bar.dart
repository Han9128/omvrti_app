import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omvrti_app/core/constants/constants.dart';

class OmvrtiAppBar extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBackPressed;

  const OmvrtiAppBar({super.key, this.showBack = false, this.onBackPressed});

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
      child: Container(
        color: AppColors.surface,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLeftIcon(context),
                _buildLogo(),
                _buildProfileAvatar(context),
                // const CircleAvatar(
                //   radius: 20,
                //   backgroundImage: NetworkImage(
                //     'https://i.pravatar.cc/150?img=12',
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftIcon(BuildContext context) {
    if (showBack) {
      return GestureDetector(
        onTap: onBackPressed ?? () => Navigator.pop(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(AppIcons.back, color: AppColors.textPrimary, size: 24),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Scaffold.of(context).openDrawer();
      },
      child: Icon(AppIcons.menu, color: AppColors.textPrimary, size: 40),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      height: 40,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Om',
              style: AppTextStyles.h1.copyWith(
                color: const Color(0xFF1A3C8F),
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: 'V',
              style: AppTextStyles.h1.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: 'rti.ai',
              style: AppTextStyles.h1.copyWith(
                color: const Color(0xFF1A3C8F),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Scaffold.of(context).openEndDrawer();
      },
      child: const CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
      ),
    );
  }
}
