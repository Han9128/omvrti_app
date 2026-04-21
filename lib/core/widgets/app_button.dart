// Two reusable button widgets used across all screens:
//   AppFilledButton   → the red "View Flight >", "Confirm Booking >" buttons
//   AppOutlinedButton → the ghost "Edit Trip", "Edit Flight" buttons

// ═══════════════════════════════════════════════════════════════
// FILLED BUTTON
// The red solid button — primary action on every screen
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:omvrti_app/core/constants/constants.dart';

class AppFilledButton extends StatelessWidget {
  // The button label — "View Flight", "Confirm Booking" etc.
  final String text;

  // VoidCallback = a function that takes no arguments and returns nothing
  // Example: () { print('tapped'); }
  // The ? makes it nullable — if null, button is automatically disabled
  // Flutter's ElevatedButton grays out when onPressed is null — built-in!

  final VoidCallback? onPressed;

  // Optional icon shown to the RIGHT of the text
  // null = no icon (just text)
  final IconData? icon;

  // When true: hides text+icon, shows a small spinner instead
  // Used when an API call is in progress after button tap
  // Default: false
  final bool isLoading;

  // Optional override for background color
  // Default: AppColors.accent (red-orange)
  // Use case: if you ever need a green or blue filled button
  final Color? backgroundColor;

  // Optional fixed width
  // Default: double.infinity (full width)
  // Use case: if you need a button that doesn't stretch full width
  final double? width;

  // constructor
  const AppFilledButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // SizedBox controls the button's width
      // If width is provided, use it. Otherwise stretch full width.

      // ?? is null coalescing operator it basically means:
      /* if (width != null) {
          return width;
        } else {
          return double.infinity;
        }*/

      // width: width ?? double.infinity,
      height: 50,

      child: ElevatedButton(
        // / If isLoading is true, disable the button
        // by passing null to onPressed
        // This prevents multiple-taps while an API call is running
        onPressed: isLoading ? null : onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textWhite,

          // disabled colors - when onpressed is null
          disabledBackgroundColor: AppColors.textMuted,
          disabledForegroundColor: AppColors.textSecondary,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),

          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),

        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: AppColors.surface,
          strokeWidth: 2,
        ),
      );
    }

    // if icon is not provided return text only

    if (icon == null) {
      return Text(
        text,
        style: AppTextStyles.button.copyWith(color: AppColors.textWhite),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.button.copyWith(color: AppColors.textWhite),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Icon(icon, color: AppColors.textWhite, size: 20),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// OUTLINED BUTTON
// The ghost button — secondary action on every screen
// ═══════════════════════════════════════════════════════════════

class AppOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? borderColor;
  final IconData? icon;
  final double? width;

  const AppOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.borderColor,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = borderColor ?? AppColors.accent;

    return SizedBox(
      // width: width ?? double.infinity,
      height: 50,

      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),

          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        child: _buildChild(color),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(color: color, strokeWidth: 2),
      );
    }

    // if icon is not provided return text only

    if (icon == null) {
      return Text(text, style: AppTextStyles.button.copyWith(color: color));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: AppTextStyles.button.copyWith(color: color)),
        const SizedBox(width: AppSpacing.xs),
        Icon(icon, color: color, size: 20),
      ],
    );
  }
}
