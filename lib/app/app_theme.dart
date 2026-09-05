import 'package:flutter/material.dart';

const emberOrange = Color(0xFFFF8A2A);
const emberDark = Color(0xFF181411);
const emberSurface = Color(0xFF241D18);

ThemeData buildJChessTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: emberOrange,
    brightness: Brightness.dark,
    surface: emberSurface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: emberDark,
    fontFamily: 'sans-serif',
    splashFactory: InkSparkle.splashFactory,
    cardTheme: CardThemeData(
      color: emberSurface.withValues(alpha: .88),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: emberOrange,
        foregroundColor: const Color(0xFF211308),
        minimumSize: const Size(0, 54),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: const Color(0xF51A1613),
      indicatorColor: emberOrange.withValues(alpha: .22),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? emberOrange
              : Colors.white60,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF332820),
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

