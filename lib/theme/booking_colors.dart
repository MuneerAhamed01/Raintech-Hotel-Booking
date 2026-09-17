import 'package:flutter/material.dart';

abstract final class BookingColors {
  static const navy = Color(0xFF153243);
  static const navyLight = Color(0xFF1E4556);
  static const gold = Color(0xFFC9A36A);
  static const goldSoft = Color(0x33C9A36A);
  static const cream = Color(0xFFF4EFE6);
  static const creamDark = Color(0xFFE8E0D2);
  static const ink = Color(0xFF1C1917);
  static const muted = Color(0xFF7C746A);
  static const soldOut = Color(0xFFB8B0A6);

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navy,
        primary: navy,
        secondary: gold,
        surface: cream,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: creamDark,
    );
  }
}
