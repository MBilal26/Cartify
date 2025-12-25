import 'package:flutter/material.dart';

class AppGradients {
  static LinearGradient get splashBackground => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColors.isDarkMode
        ? [
      AppColors.customGradientStart ?? Color(0xFF008080),
      AppColors.customGradientEnd ?? Color.fromARGB(255, 28, 28, 28)
    ]
        : [
      AppColors.customGradientStart ?? Color(0xFF008080),
      AppColors.customGradientEnd ?? Color.fromARGB(255, 255, 255, 255)
    ],
  );
}

class AppColors {
  static bool isDarkMode = false;

  // Custom color overrides (null means use default)
  static Color? customAccent;
  static Color? customBackground;
  static Color? customTextPrimary;
  static Color? customTextSecondary;
  static Color? customCard;
  static Color? customBorder;
  static Color? customAccentBG;
  static Color? customGradientStart;
  static Color? customGradientEnd;

  static void toggleTheme() {
    isDarkMode = !isDarkMode;
  }

  // Reset all custom colors to default
  static void resetToDefaults() {
    customAccent = null;
    customBackground = null;
    customTextPrimary = null;
    customTextSecondary = null;
    customCard = null;
    customBorder = null;
    customAccentBG = null;
    customGradientStart = null;
    customGradientEnd = null;
  }

  // Main Brand Colors
  static Color get primary => customBackground ??
      (isDarkMode
          ? Color.fromARGB(255, 255, 255, 255)
          : Color.fromARGB(255, 255, 255, 255));

  static Color get secondary => customTextPrimary ??
      (isDarkMode
          ? Color.fromARGB(255, 255, 255, 255)
          : Color.fromARGB(255, 28, 28, 28));

  static Color get accent => customAccent ?? Color(0xFF008080);

  static Color get accentBG =>
      customAccentBG ?? (isDarkMode ? Color(0xFF008080) : Color.fromARGB(255, 255, 255, 255));

  // Background Colors
  static Color get background =>
      customBackground ?? (isDarkMode ? Color.fromARGB(255, 28, 28, 28) : Colors.white);

  static Color get darkBackground => Color.fromARGB(255, 28, 28, 28);

  // Text Colors
  static Color get textPrimary => customTextPrimary ?? (isDarkMode ? Colors.white : Colors.black);

  static Color get textSecondary => customTextSecondary ??
      (isDarkMode
          ? Color.fromARGB(255, 180, 180, 180)
          : Color.fromARGB(255, 100, 100, 100));

  static const Color textaccent = Color(0xFF008080);

  // Error, Success, Warning
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;
  static const Color warning = Colors.amber;

  // Extra
  static Color get card =>
      customCard ?? (isDarkMode ? Color.fromARGB(255, 40, 40, 40) : Color(0xFFFFFFFF));

  static Color get border =>
      customBorder ?? (isDarkMode ? Color.fromARGB(255, 60, 60, 60) : Color(0xFFE0E0E0));
}