import 'package:flutter/material.dart';
import 'colors.dart'; // Make sure this file exists too!

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.gradientStart,
      scaffoldBackgroundColor: AppColors.backgroundEnd,
      fontFamily: 'Poppins', // Optional: requires adding font to pubspec.yaml
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gradientStart,
        primary: AppColors.gradientStart,
        secondary: Color(0xFF3BF673), // Accent Green
      ),
      // This ensures your TextFields and Buttons match the Glassmorphism look
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
