import 'package:flutter/material.dart';

class Theme {
  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF5555),
      brightness: Brightness.light,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0xFFFF5555),
    ),
  );

  static ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF5555),
      brightness: Brightness.dark,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0xFF802B2B),
    ),
  );
}
