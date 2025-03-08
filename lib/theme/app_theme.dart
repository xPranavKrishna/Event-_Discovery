import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary color - Purple as seen in the code
  static const Color primaryColor = Color(0xFF5E43C3);
  static const Color primaryVariantColor = Color(0xFF4A35A0);

  // Secondary colors
  static const Color secondaryColor = Color(0xFFFFFFFF); // White
  static const Color secondaryVariantColor = Color(0xFFF2F2F2); // Light Gray

  // Background colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF2D2A3C);

  // Text colors
  static const Color textLight = Color(0xFF333333);
  static const Color textDark = Color(0xFFFFFFFF);

  // Error colors
  static const Color errorColor = Color(0xFFB00020);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
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
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      // Display styles - using Londrina Solid for headings/buttons
      displayLarge: GoogleFonts.londrinaSolid(
        color: textLight,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.londrinaSolid(
        color: textLight,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.londrinaSolid(
        color: textLight,
      ),
      // Headline styles
      headlineMedium: GoogleFonts.londrinaSolid(
        color: textLight,
      ),
      headlineSmall: GoogleFonts.londrinaSolid(
        color: textLight,
      ),
      // Title styles
      titleLarge: GoogleFonts.londrinaSolid(
        color: textLight,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.aBeeZee(
        color: textLight,
      ),
      titleSmall: GoogleFonts.aBeeZee(
        color: textLight,
      ),
      // Body styles - using ABeeZee for body text
      bodyLarge: GoogleFonts.aBeeZee(
        color: textLight,
      ),
      bodyMedium: GoogleFonts.aBeeZee(
        color: textLight,
      ),
      bodySmall: GoogleFonts.aBeeZee(
        color: textLight,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: errorColor, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      hintStyle: GoogleFonts.arOneSans(
        fontSize: 16,
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
        textStyle: GoogleFonts.londrinaSolid(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: GoogleFonts.aBeeZee(
          fontSize: 14,
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
    // Add bottom app bar theme
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Color(0xFFF2F2F2),
      elevation: 0,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      primaryContainer: primaryVariantColor,
      secondary: secondaryColor,
      secondaryContainer: secondaryVariantColor,
      surface: Color(0xFF2D2A3C),
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
    textTheme: TextTheme(
      // Display styles - using Londrina Solid for headings/buttons
      displayLarge: GoogleFonts.londrinaSolid(
        color: textDark,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.londrinaSolid(
        color: textDark,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.londrinaSolid(
        color: textDark,
      ),
      // Headline styles
      headlineMedium: GoogleFonts.londrinaSolid(
        color: textDark,
      ),
      headlineSmall: GoogleFonts.londrinaSolid(
        color: textDark,
      ),
      // Title styles
      titleLarge: GoogleFonts.londrinaSolid(
        color: textDark,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.aBeeZee(
        color: textDark,
      ),
      titleSmall: GoogleFonts.aBeeZee(
        color: textDark,
      ),
      // Body styles - using ABeeZee for body text
      bodyLarge: GoogleFonts.aBeeZee(
        color: textDark,
      ),
      bodyMedium: GoogleFonts.aBeeZee(
        color: textDark,
      ),
      bodySmall: GoogleFonts.aBeeZee(
        color: textDark,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: errorColor, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      hintStyle: GoogleFonts.arOneSans(
        fontSize: 16,
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
        textStyle: GoogleFonts.londrinaSolid(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: GoogleFonts.aBeeZee(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF3D3656),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    // Add bottom app bar theme for dark mode
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Color(0xFF2D2A3C),
      elevation: 0,
    ),
  );
}
