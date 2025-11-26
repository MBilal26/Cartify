import 'package:flutter/material.dart';

class AppGradients {
  static const LinearGradient splashBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4EB9B1), // teal-ish top color
      Colors.white, // smooth fade to white
    ],
  );
}

class AppColors {
  // Main Brand Colors
  static const Color primary = Color.fromARGB(255, 255, 255, 255); 
  static const Color secondary = Color.fromARGB(255, 0, 0, 0); 
  static const Color accent = Color.fromRGBO(0, 128, 128, 100); 

  // Background Colors
  static const Color background = Colors.white; 
  static const Color darkBackground = Color.fromARGB(255, 6, 2, 2); 

  // Text Colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.black54;
  static const Color textWhite = Colors.white;

  // Error, Success, Warning
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;

  //Extra
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
}
