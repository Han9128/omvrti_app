import 'package:flutter/material.dart';
import 'package:omvrti_app/core/constants/constants.dart';

class OmvrtiAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(80);

  // showBack controls which icon appears on the left
  // false (default) → hamburger menu ☰
  // true            → back arrow ←

  final bool showBack;

  // onBackPressed lets the caller define what happens when back is tapped
  // If not provided, it uses Navigator.pop() by default
  // VoidCallback? is a function type and is an optional function that takes no arguments, returns nothing
  final VoidCallback? onBackPressed;

  const OmvrtiAppBar({
    super.key, // we provide key to constructor to give a unique id to widget this helps flutter in tracking and efficiently building widgets
    this.showBack = false,
    this.onBackPressed,
  });

  @override
  // build() defines the UI of the widget
  // It can run multiple times, so avoid heavy logic here
  Widget build(BuildContext context) {
    return Container(
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
              // this is either menu icon or back icon depending on screen
              _buildLeftIcon(context),

              // omvrti.ai logo text
              _buildLogo(),

              // the profile picture
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=12',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftIcon(BuildContext context) {
    if (showBack) {
      return GestureDetector(
        // GestureDetector wraps any widget and makes it tappable
        // It is like InkWell but without the ripple effect
        // We use it here because the back button is a custom styled widget

        // If widget uses Navigator / Theme / MediaQuery → needs context. context is position of widget in widget tree
        onTap: onBackPressed ?? () => Navigator.pop(context),

        // ?? means: if onBackPressed was provided by caller, use it
        //           if not provided (null), fall back to Navigator.pop(context)
        //
        // Navigator.pop(context) → goes back to previous screen

        // design the back icon
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
        // implement this when hamburger menu overlay is coded
      },

      child: Icon(AppIcons.menu, color: AppColors.textPrimary, size: 40),
    );
  }

  Widget _buildLogo() {
    // RichText allows multiple text styles in a single line
    // Useful when different parts of text need different styling
    return SizedBox(
      height: 40,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Om',
              style: AppTextStyles.h1.copyWith(
                color: Color(0xFF1A3C8F),
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
                color: Color(0xFF1A3C8F),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
