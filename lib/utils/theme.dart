import 'package:flutter/material.dart';

class UChatTheme {
  static getLightTheme() {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      brightness: Brightness.light,
      backgroundColor: const Color(0xFFF7F7FC),
      cardColor: const Color(0xFFADB5BD),
      shadowColor: Colors.black,
      primaryColor: const Color(0xFFD84D4D),
      dividerColor: const Color(0xFFEDEDED),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFD84D4D),
        secondary: const Color(0xFFD84D4D).withOpacity(0.12),
      ),
      fontFamily: 'Montserrat',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF000000),
        ),
        headlineMedium: TextStyle(
          color: Color(0xFFFFFFFF),
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF606060),
        ),
        bodySmall: TextStyle(
          color: Color(0xFFADB5BD),
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFA4A4A4),
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFD84D4D),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFADB5BD),
        ),
      ),
    );
  }
}
