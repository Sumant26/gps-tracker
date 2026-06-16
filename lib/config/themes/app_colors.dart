import 'package:flutter/material.dart';

/// Centralized color palette for the GPS Tracker application.
/// All colors are derived from the design specification.
class AppColors {
  AppColors._();

  /// Primary brand color — muted teal
  static const Color primary = Color(0xFF7D9D9C);

  /// Secondary color — soft sage
  static const Color secondary = Color(0xFFA6C1B9);

  /// App background
  static const Color background = Color(0xFFF4F6F8);

  /// Card / sheet surface
  static const Color surface = Color(0xFFFFFFFF);

  /// Warm accent — sandy beige
  static const Color accent = Color(0xFFD8C3A5);

  /// Error / destructive actions
  static const Color error = Color(0xFFD88C8C);

  /// Text colors
  static const Color textPrimary = Color(0xFF1E2A2A);
  static const Color textSecondary = Color(0xFF5E7070);
  static const Color textHint = Color(0xFF9AB0AF);

  /// Tracking active indicator
  static const Color trackingActive = Color(0xFF5C9E8A);
  static const Color trackingInactive = Color(0xFFB0C4C4);

  /// Dividers and borders
  static const Color divider = Color(0xFFDDE6E5);
  static const Color border = Color(0xFFCAD8D7);
}
