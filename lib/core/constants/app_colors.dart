import 'package:flutter/material.dart';

class AppColors {
  // private constructore to prevent any instantiation, e.g can't do this final colors = AppColors();
  AppColors._();

  // Use static to directly access the color of this color as static properties
  // are available at class level and does not require instantiating any object

  // Brand Colors

  static const Color primary = Color(0xFF3B82F6); // blue color for card base
  static const Color accent = Color(0xFFCC3300); // red-orange for buttons

  // text colors

  static const Color textPrimary = Color(0xFF0F1117); // black - primary text
  static const Color textSecondary = Color(0xFF4A5168);
  static const Color textMuted = Color(0xFF9BA3BF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // semantic colors
  static const Color success = Color(0xFF10B981); // green - success
  static const Color warning = Color(0xFFFFB800); // gold — rewards, loyalty
  static const Color error = Color(0xFFFF3B30); // red - errpr

  //background colors
  static const Color pageBackground = Color(0xFFE5E5EA); //light gray - page bg
  static const Color surface = Color(0xFFFFFFFF); // white — cards
}
