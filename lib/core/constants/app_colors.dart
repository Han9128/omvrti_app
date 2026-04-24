import 'package:flutter/material.dart';

class AppColors {
  // private constructore to prevent any instantiation, e.g can't do this final colors = AppColors();
  AppColors._();

  // Use static to directly access the color of this color as static properties
  // are available at class level and does not require instantiating any object

  // Brand Colors

  static const Color primary = Color(0xFF3874e1); // blue color for card base
  static const Color accent = Color(0xFFCC3300); // red-orange for buttons
  static const Color red_stroke = Color(0xFF952703);

  // text colors

  static const Color textPrimary = Color(0xFF333333); // black - primary text
  static const Color textSecondary = Color(0xFF919191);
  static const Color textMuted = Color(0xFF9BA3BF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // semantic colors
  static const Color success = Color(0xFF169616); // green - success
  static const Color warning = Color(0xFFFFB800); // gold — rewards, loyalty
  static const Color error = Color(0xFFFF3B30); // red - error
  static const Color pending = Color(0xFFfff1c6);
  static const Color pending_stroke = Color(0xFFffc107);
  static const Color active = Color(0xFFd5ffd7);
  static const Color active_stroke = Color(0xFF169616);

  //background colors
  static const Color pageBackground = Color(0xFFf7f7f7); //light gray - page bg
  static const Color surface = Color(0xFFFFFFFF); // white — cards
}
