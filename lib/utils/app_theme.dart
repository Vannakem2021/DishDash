import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF4B3A);
  static const Color secondaryColor = Color(0xFFFA4A0C);
  static const Color textColor = Color(0xFF000000);
  static const Color lightTextColor = Color(0xFF9A9A9D);
  static const Color backgroundColor = Color(0xFFF2F2F2);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color successColor = Color(0xFF4CD964);

  static ThemeData themeData() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
      fontFamily: 'IBMPlexSans',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'SyneMono',
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontFamily: 'SyneMono',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displaySmall: TextStyle(
          fontFamily: 'SyneMono',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SyneMono',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: lightTextColor,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'SyneMono',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: lightTextColor,
        ),
      ),
    );
  }
}
