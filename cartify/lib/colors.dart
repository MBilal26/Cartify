import 'package:flutter/material.dart';

class AppGradients {
  static const LinearGradient splashBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF008080), Color.fromARGB(255, 255, 255, 255)],
  );
  static const LinearGradient darksplashBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF008080), Color.fromARGB(255, 28, 28, 28)],
  );
}

class AppColors {
  // Main Brand Colors
  static const Color primary = Color.fromARGB(255, 255, 255, 255);
  static const Color secondary = Color.fromARGB(255, 28, 28, 28);
  static const Color accent = Color(0xFF008080);

  // Background Colors
  static const Color background = Colors.white;
  static const Color darkBackground = Color.fromARGB(255, 28, 28, 28);

  // Text Colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color.fromARGB(255, 255, 255, 255);
  static const Color textaccent = Color(0xFF008080);

  // Error, Success, Warning
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;
  static const Color warning = Colors.amber;

  //Extra
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
}
