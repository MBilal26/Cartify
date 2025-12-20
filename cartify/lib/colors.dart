import 'package:flutter/material.dart';

class AppGradients {
  static LinearGradient get splashBackground => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColors.isDarkMode 
      ? [Color(0xFF008080), Color.fromARGB(255, 28, 28, 28)]
      : [Color(0xFF008080), Color.fromARGB(255, 255, 255, 255)],
  );
}

class AppColors {
  static bool isDarkMode = false;

  static void toggleTheme() {
    isDarkMode = !isDarkMode;
  }

  // Main Brand Colors
  static Color get primary => isDarkMode 
    ? Color.fromARGB(255, 255, 255, 255) 
    : Color.fromARGB(255, 255, 255, 255);
  
  static Color get secondary => isDarkMode 
    ? Color.fromARGB(255, 255, 255, 255)
    : Color.fromARGB(255, 28, 28, 28);
  
  static const Color accent = Color(0xFF008080);

  // Background Colors
  static Color get background => isDarkMode 
    ? Color.fromARGB(255, 28, 28, 28) 
    : Colors.white;
  
  static Color get darkBackground => Color.fromARGB(255, 28, 28, 28);

  // Text Colors
  static Color get textPrimary => isDarkMode 
    ? Colors.white 
    : Colors.black;
  
  static Color get textSecondary => isDarkMode 
    ? Color.fromARGB(255, 180, 180, 180)
    : Color.fromARGB(255, 100, 100, 100);
  
  static const Color textaccent = Color(0xFF008080);

  // Error, Success, Warning
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;
  static const Color warning = Colors.amber;

  // Extra
  static Color get card => isDarkMode 
    ? Color.fromARGB(255, 40, 40, 40)
    : Color(0xFFFFFFFF);
  
  static Color get border => isDarkMode 
    ? Color.fromARGB(255, 60, 60, 60)
    : Color(0xFFE0E0E0);
}