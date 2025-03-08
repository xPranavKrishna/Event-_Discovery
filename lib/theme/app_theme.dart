import 'package:flutter/material.dart';

class AppTheme {
  // Primary color - Burgundy as seen in the image
  static const Color primaryColor = Color(0xFF800020);
  static const Color primaryVariantColor = Color(0xFF5C0018);

  // Secondary colors
  static const Color secondaryColor = Color(0xFFFFFFFF); // White
  static const Color secondaryVariantColor = Color(0xFFF5F5F5); // Light Gray

  // Accent colors
  static const Color accentColor1 = Color(0xFFAA0030); // Lighter Burgundy
  static const Color accentColor2 = Color(0xFFCCACAC); // Light Pink/Gray
  static const Color accentColor3 = Color(0xFF550015); // Darker Burgundy

  // Background colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF2D0010);

  // Text colors
  static const Color textLight = Color(0xFF333333);
  static const Color textDark = Color(0xFFFFFFFF);

  // Error colors
  static const Color errorColor = Color(0xFFB00020);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'LondrinaSolid', // Default font family
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryVariantColor,
      secondary: secondaryColor,
      secondaryContainer: secondaryVariantColor,
      surface: Colors.white,
      background: backgroundLight,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor:
        primaryColor, // Using primary color for main backgrounds
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'LondrinaSolid',
          color: textLight,
          fontWeight: FontWeight.bold),
      displayMedium: TextStyle(
          fontFamily: 'LondrinaSolid',
          color: textLight,
          fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontFamily: 'LondrinaSolid', color: textLight),
      headlineMedium: TextStyle(fontFamily: 'LondrinaSolid', color: textLight),
      headlineSmall: TextStyle(fontFamily: 'LondrinaSolid', color: textLight),
      titleLarge: TextStyle(
          fontFamily: 'LondrinaSolid',
          color: textLight,
          fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontFamily: 'LondrinaSolid', color: textLight),
      titleSmall: TextStyle(fontFamily: 'LondrinaSolid', color: textLight),
      bodyLarge: TextStyle(fontFamily: 'LondrinaSolid', color: textLight),
      bodyMedium: TextStyle(fontFamily: 'LondrinaSolid', color: textLight),
      bodySmall: TextStyle(fontFamily: 'LondrinaSolid', color: textLight),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: errorColor, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      hintStyle: const TextStyle(
        fontFamily: 'LondrinaSolid',
        fontSize: 20,
        color: Colors.black45,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'LondrinaSolid',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: const TextStyle(
          fontFamily: 'LondrinaSolid',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'LondrinaSolid', // Default font family
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      primaryContainer: primaryVariantColor,
      secondary: secondaryColor,
      secondaryContainer: secondaryVariantColor,
      surface: Color(0xFF330015),
      background: backgroundDark,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'LondrinaSolid',
          color: textDark,
          fontWeight: FontWeight.bold),
      displayMedium: TextStyle(
          fontFamily: 'LondrinaSolid',
          color: textDark,
          fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontFamily: 'LondrinaSolid', color: textDark),
      headlineMedium: TextStyle(fontFamily: 'LondrinaSolid', color: textDark),
      headlineSmall: TextStyle(fontFamily: 'LondrinaSolid', color: textDark),
      titleLarge: TextStyle(
          fontFamily: 'LondrinaSolid',
          color: textDark,
          fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontFamily: 'LondrinaSolid', color: textDark),
      titleSmall: TextStyle(fontFamily: 'LondrinaSolid', color: textDark),
      bodyLarge: TextStyle(fontFamily: 'LondrinaSolid', color: textDark),
      bodyMedium: TextStyle(fontFamily: 'LondrinaSolid', color: textDark),
      bodySmall: TextStyle(fontFamily: 'LondrinaSolid', color: textDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: errorColor, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      hintStyle: const TextStyle(
        fontFamily: 'LondrinaSolid',
        fontSize: 20,
        color: Colors.grey,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'LondrinaSolid',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: const TextStyle(
          fontFamily: 'LondrinaSolid',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF400020),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
