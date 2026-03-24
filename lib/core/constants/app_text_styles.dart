import 'package:flutter/material.dart';
import 'package:omvrti_app/core/constants/app_colors.dart';
import 'package:omvrti_app/core/constants/font_families.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: AppFontFamilies.heading,
    // fallback families if given fontFamily is not present
    fontFamilyFallback: [
      AppFontFamilies.body,
      'Roboto',
      'San Francisco',
      'Arial',
    ],
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: AppFontFamilies.heading,
    fontFamilyFallback: [
      AppFontFamilies.body,
      'Roboto',
      'San Francisco',
      'Arial',
    ],
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: AppFontFamilies.heading,
    fontFamilyFallback: [
      AppFontFamilies.body,
      'Roboto',
      'San Francisco',
      'Arial',
    ],
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: AppFontFamilies.heading,
    fontFamilyFallback: [
      AppFontFamilies.body,
      'Roboto',
      'San Francisco',
      'Arial',
    ],
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Body Styles — DM Sans ─────────────────────────────────
  // Used for: paragraphs, descriptions, card content, labels

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFontFamilies.body,
    fontFamilyFallback: ['Roboto', 'San Francisco', 'Arial'],
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
    height: 1.5, // body text needs more line height for readability
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFontFamilies.body,
    fontFamilyFallback: ['Roboto', 'San Francisco', 'Arial'],
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFontFamilies.body,
    fontFamilyFallback: ['Roboto', 'San Francisco', 'Arial'],
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, // gray for small supporting text
    height: 1.4,
  );

  // ── Special Styles ────────────────────────────────────────

  // Price amounts like "$515", "$3,500" — heading font, green
  static const TextStyle price = TextStyle(
    fontFamily: AppFontFamilies.heading,
    fontFamilyFallback: [AppFontFamilies.body, 'Roboto', 'Arial'],
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
  );

  // Small gray labels like "Purpose", "Estimated Budget"
  static const TextStyle label = TextStyle(
    fontFamily: AppFontFamilies.body,
    fontFamilyFallback: ['Roboto', 'San Francisco', 'Arial'],
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontFamily: AppFontFamilies.body,
    fontFamilyFallback: ['Roboto', 'San Francisco', 'Arial'],
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );
}
